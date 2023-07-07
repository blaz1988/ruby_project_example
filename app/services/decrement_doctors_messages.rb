# frozen_string_literal: true

class DecrementDoctorsMessages
  include Callable

  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    raise NON_DOCTOR_RECIPIENT unless current_user.is_doctor?

    current_user.inbox.decrement!(:unread_messages)
  end

  private

  attr_reader :current_user
end
