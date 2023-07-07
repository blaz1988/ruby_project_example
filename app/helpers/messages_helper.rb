# frozen_string_literal: true

module MessagesHelper
  def display_sender(message)
    sender_name = message.outbox.user.full_name
    sender_name.prepend('Dr.') if message.outbox.user.is_doctor?
    "From: #{sender_name}"
  end

  def display_receipent(message)
    receipent_name = message.inbox.user.full_name
    receipent_name.prepend('Dr.') if message.inbox.user.is_doctor?
    "To: #{receipent_name}"
  end

  def display_box
    return 'Inbox' if params[:box_type].nil?

    params[:box_type].to_s.capitalize
  end

  def display_user(message)
    return display_receipent(message) if params[:box_type] == 'outbox'

    message.read? ? display_sender(message) : "#{display_sender(message)} - UNREAD"
  end

  def display_reply
    return 'Inbox' if params[:box_type].nil?

    params[:box_type].to_s.capitalize
  end

  def reply_link(message)
    return unless message.outbox.user.is_doctor?

    link_to 'Reply', new_message_path(parent_id: message.id), class: 'btn btn-primary'
  end
end
