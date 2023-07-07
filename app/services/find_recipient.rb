# frozen_string_literal: true

class FindRecipient
  include Callable

  def initialize(parent_message_id:, doctor:, admin:)
    @parent_message_id = parent_message_id
    @doctor = doctor
    @admin = admin
  end

  def call
    raise PARENT_MESSAGE_NOT_EXISTS unless parent_message.present?

    recipient
  end

  private

  attr_reader :parent_message_id, :doctor, :admin

  def recipient
    parent_message.created_at < 1.week.ago ? admin : doctor
  end

  def parent_message
    @parent_message ||= Message.find_by(id: parent_message_id)
  end
end
