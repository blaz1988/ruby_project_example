# frozen_string_literal: true

class Outbox < ApplicationRecord
  belongs_to :user
  has_many :messages
end
