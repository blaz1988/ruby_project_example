# frozen_string_literal: true

class AddUnreadMessagesToInboxes < ActiveRecord::Migration[6.1]
  def change
    add_column :inboxes, :unread_messages, :integer, default: 0
  end
end
