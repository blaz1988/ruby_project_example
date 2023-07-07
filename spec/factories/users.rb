# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :admin do
      is_patient { false }
      is_doctor { false }
      is_admin { true }
    end

    trait :patient do
      is_patient { true }
      is_doctor { false }
      is_admin { false }
    end

    trait :doctor do
      is_patient { false }
      is_doctor { true }
      is_admin { false }
    end

    factory :admin, traits: [:admin]
    factory :patient, traits: [:patient]
    factory :doctor, traits: [:doctor]
  end
end
