# frozen_string_literal: true

class ReadMessages
  include Callable

  def initialize(user:, box_type:)
    @user = user
    @box_type = box_type
  end

  def call
    messages
  end

  private

  attr_reader :user, :box_type

  def messages
    Message.send(box_type, user)
  end

  def recipient
    message.inbox.user
  end
end
