# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    body { Faker::Lorem.paragraph }
    outbox
    inbox
    read { false }
  end
end
