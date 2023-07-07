# frozen_string_literal: true

class ReadMessage
  include Callable

  def initialize(message_id:, current_user_id:)
    @message_id = message_id
    @current_user_id = current_user_id
  end

  def call
    raise MESSAGE_NOT_FOUND unless message.present?

    mark_as_read if current_user_inbox?
    message
  end

  private

  attr_reader :message_id, :current_user_id

  def message
    @message ||= Message.find_by(id: message_id)
  end

  def current_user_inbox?
    message.inbox.user_id == current_user_id
  end

  def mark_as_read
    return if message.read?

    message.read = true
    message.save
  end
end
