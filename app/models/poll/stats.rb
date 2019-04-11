class Poll::Stats
  include Statisticable
  alias_method :poll, :resource

  CHANNELS = Poll::Voter::VALID_ORIGINS

  def self.stats_methods
    super +
      %i[total_valid_votes total_white_votes total_null_votes
         total_participants_web total_web_valid total_web_white total_web_null
         total_participants_booth total_booth_valid total_booth_white total_booth_null
         total_participants_letter total_letter_valid total_letter_white total_letter_null
         total_participants_web_percentage total_participants_booth_percentage
         total_participants_letter_percentage
         valid_percentage_web valid_percentage_booth valid_percentage_letter total_valid_percentage
         white_percentage_web white_percentage_booth white_percentage_letter total_white_percentage
         null_percentage_web null_percentage_booth null_percentage_letter total_null_percentage]
  end

  def total_participants
    total_participants_web + total_participants_booth
  end

  def channels
    CHANNELS.select { |channel| send(:"total_participants_#{channel}") > 0 }
  end

  CHANNELS.each do |channel|
    define_method :"total_participants_#{channel}" do
      send(:"total_#{channel}_valid") +
        send(:"total_#{channel}_white") +
        send(:"total_#{channel}_null")
    end

    define_method :"total_participants_#{channel}_percentage" do
      calculate_percentage(send(:"total_participants_#{channel}"), total_participants)
    end
  end

  def total_web_valid
    voters.where(origin: "web").count - total_web_white
  end

  def total_web_white
    return 0 unless poll.questions.second.present?
    double_white = (Poll::Answer.where(answer: "En blanco", question: poll.questions.first).pluck(:author_id) & Poll::Answer.where(answer: "En blanco", question: poll.questions.second).pluck(:author_id)).uniq.count
    first_total =  Poll::Answer.where(answer: "En blanco", question: poll.questions.first).pluck(:author_id).count
    first_total -= (Poll::Answer.where(answer: "En blanco", question: poll.questions.first).pluck(:author_id) & Poll::Answer.where(answer: poll.questions.second.question_answers.where(given_order: 1).first.title, question: poll.questions.second).pluck(:author_id)).uniq.count
    first_total -= (Poll::Answer.where(answer: "En blanco", question: poll.questions.first).pluck(:author_id) & Poll::Answer.where(answer: poll.questions.second.question_answers.where(given_order: 2).first.title, question: poll.questions.second).pluck(:author_id)).uniq.count
    first_total -= double_white

    second_total =  Poll::Answer.where(answer: "En blanco", question: poll.questions.second).pluck(:author_id).count
    second_total -= (Poll::Answer.where(answer: poll.questions.first.question_answers.where(given_order: 1).first.title, question: poll.questions.first).pluck(:author_id) & Poll::Answer.where(answer: "En blanco", question: poll.questions.second).pluck(:author_id)).uniq.count
    second_total -= (Poll::Answer.where(answer: poll.questions.first.question_answers.where(given_order: 2).first.title, question: poll.questions.first).pluck(:author_id) & Poll::Answer.where(answer: "En blanco", question: poll.questions.second).pluck(:author_id)).uniq.count
    second_total -= double_white

    double_white + first_total + second_total
  end

  def total_web_null
    0
  end

  def total_booth_valid
    recounts.sum(:total_amount)
  end

  def total_booth_white
    recounts.sum(:white_amount)
  end

  def total_booth_null
    recounts.sum(:null_amount)
  end

  def total_letter_valid
    voters.where(origin: "letter").count # TODO: count only valid votes
  end

  def total_letter_white
    0 # TODO
  end

  def total_letter_null
    0 # TODO
  end

  %i[valid white null].each do |type|
    CHANNELS.each do |channel|
      define_method :"#{type}_percentage_#{channel}" do
        calculate_percentage(send(:"total_#{channel}_#{type}"), send(:"total_#{type}_votes"))
      end
    end

    define_method :"total_#{type}_votes" do
      send(:"total_web_#{type}") + send(:"total_booth_#{type}")
    end

    define_method :"total_#{type}_percentage" do
      calculate_percentage(send(:"total_#{type}_votes"), total_participants)
    end
  end

  def total_no_demographic_data
    super + total_unregistered_booth
  end

  private

    def participant_ids
      voters
    end

    def voters
      @voters ||= poll.voters.select(:user_id)
    end

    def recounts
      @recounts ||= poll.recounts
    end

    def total_registered_booth
      voters.where(origin: "booth").count
    end

    def total_unregistered_booth
      [total_participants_booth - total_registered_booth, 0].max
    end

    stats_cache(*stats_methods)

    def stats_cache(key, &block)
      Rails.cache.fetch("polls_stats/#{poll.id}/#{key}/#{version}", &block)
    end

end
