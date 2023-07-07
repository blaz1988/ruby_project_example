# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReadMessage do
  let(:subject) do
    described_class.call(message_id: message_id, current_user_id: user.id)
  end

  let(:message_id) { message.id }
  let(:message) { create(:message, inbox: create(:inbox, user: user)) }
  let(:user) { create(:user, :patient) }

  describe '#call' do
    context 'when message exists' do
      it 'returns the message', :aggregate_failures do
        expect(subject).to eq(message)
        expect(subject.read).to be_truthy
      end
    end

    context 'when message does not exist' do
      before do
        allow(Message).to receive(:find_by).with(id: message_id).and_return(nil)
        allow(message).to receive(:present?).and_return(false)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(MESSAGE_NOT_FOUND)
      end
    end
  end
end
