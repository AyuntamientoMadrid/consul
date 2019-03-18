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
         null_percentage_web null_percentage_booth null_percentage_letter total_null_percentage
         total_male_web total_male_booth total_male_letter
         total_female_web total_female_booth total_female_letter
         male_web_percentage male_booth_percentage male_letter_percentage
         female_web_percentage female_booth_percentage female_letter_percentage
         web_participants_by_age booth_participants_by_age letter_participants_by_age
         web_participants_by_geozone booth_participants_by_geozone letter_participants_by_geozone]
  end

  def total_participants
    total_participants_web + total_participants_booth
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

    define_method :"#{channel}_participants" do
      User.where(id: voters.where(origin: channel).pluck(:user_id))
    end

    define_method :"#{channel}_participants_by_age" do
      participants_by_age_for(send(:"#{channel}_participants"),
                              relative_to: :participants_between_ages)
    end

    define_method :"#{channel}_participants_by_geozone" do
      geozones.map do |geozone|
        count = send(:"#{channel}_participants").where(geozone: geozone).count
        [
          geozone.name,
          {
            count: count,
            percentage: calculate_percentage(count, participants.where(geozone: geozone).count)
          }
        ]
      end.to_h
    end

    %i[male female].each do |gender|
      define_method :"total_#{gender}_#{channel}" do
        send(:"#{channel}_participants").public_send(gender).count
      end

      define_method :"#{gender}_#{channel}_percentage" do
        calculate_percentage(
          send(:"total_#{gender}_#{channel}"),
          send(:"total_#{gender}_participants")
        )
      end
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
    0 # TODO
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

  private

    def participants
      User.where(id: voters.pluck(:user_id))
    end

    def voters
      poll.voters
    end

    def recounts
      poll.recounts
    end

    stats_cache(*stats_methods)
    stats_cache :voters, :recounts

    def stats_cache(key, &block)
      Rails.cache.fetch("polls_stats/#{poll.id}/#{key}/v12", &block)
    end

end
