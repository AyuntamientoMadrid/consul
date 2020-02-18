class ModeratedContent < ApplicationRecord
  belongs_to :comment, foreign_key: "moderable_id"
  belongs_to :moderated_text, foreign_key: "moderated_text_id"
  belongs_to :moderable, polymorphic: true

  scope :confirmed,        -> { where("confirmed_at IS NOT ?", nil) }
  scope :declined,         -> { where("declined_at IS NOT ?", nil) }
  scope :occurrence_count, -> {
    select(:moderated_text_id).group(:moderated_text_id).count
  }

  scope :remove_all_offenses, ->(id, type) {
    delete_all(moderable_id: id, moderable_type: type)
  }

  scope :remove_specific_offenses, ->(type, word_ids, id) { where(
    "moderable_type = ? AND moderated_text_id IN (?) AND moderable_id = ?",
    type, word_ids, id
  ).delete_all }
end
