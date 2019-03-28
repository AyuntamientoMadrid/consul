class Poll::Answer < ActiveRecord::Base

  belongs_to :question, -> { with_hidden }
  belongs_to :author, ->   { with_hidden }, class_name: "User", foreign_key: "author_id"

  delegate :poll, :poll_id, to: :question

  validates :question, presence: true
  validates :author, presence: true
  validates :answer, presence: true

  validates :answer, inclusion: { in: ->(a) { a.question.question_answers
                                                        .joins(:translations)
                                                        .pluck("poll_question_answer_translations.title") }},
                     unless: ->(a) { a.question.blank? }

  scope :by_author, ->(author_id) { where(author_id: author_id) }
  scope :by_question, ->(question_id) { where(question_id: question_id) }
end
