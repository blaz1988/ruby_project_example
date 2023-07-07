# frozen_string_literal: true

class IncrementDoctorsMessages
  include Callable

  def initialize(recipient:)
    @recipient = recipient
  end

  def call
    raise NON_DOCTOR_RECIPIENT unless recipient.is_doctor?

    recipient.inbox.increment!(:unread_messages)
  end

  private

  attr_reader :recipient
end
