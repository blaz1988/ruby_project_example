# frozen_string_literal: true

class CreateMessage
  include Callable

  def initialize(body:, sender:, recipient:)
    @body = body
    @sender = sender
    @recipient = recipient
  end

  def call
    save_message
    increment_unread_messages_count
    message
  end

  private

  attr_reader :body, :sender, :recipient

  def message
    @message ||= Message.new(message_params)
  end

  def message_params
    { body: body, read: false, outbox_id: sender_outbox_id, inbox_id: recipient_inbox_id }
  end

  def save_message
    message.save!
  end

  def sender_outbox_id
    sender.outbox.id
  end

  def recipient_inbox_id
    recipient.inbox.id
  end

  def increment_unread_messages_count
    IncrementDoctorsMessages.call(recipient: recipient) if recipient.is_doctor?
  end
end
