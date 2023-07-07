# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :inbox
  belongs_to :outbox

  validates :body, presence: true
  validates :body, length: { maximum: 500 }

  attr_accessor :parent_id

  scope :inbox, lambda { |user|
    includes(outbox: :user).joins(:inbox).where(inboxes: { user_id: user.id })
  }

  scope :outbox, lambda { |user|
    includes(inbox: :user).joins(:outbox).where(outboxes: { user_id: user.id })
  }
end
