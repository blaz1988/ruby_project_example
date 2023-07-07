# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReadMessages do
  describe '#call' do
    let(:subject) { described_class.call(user: user1, box_type: box_type) }

    let(:user1) { create(:user) }
    let(:inbox1) { create(:inbox, user: user1) }
    let(:outbox1) { create(:outbox, user: user1) }
    let(:user2) { create(:user) }
    let(:inbox2) { create(:inbox, user: user2) }
    let(:outbox2) { create(:outbox, user: user2) }
    let(:message1) { create(:message, inbox: inbox1) }
    let(:message2) { create(:message, inbox: inbox2) }
    let(:message3) { create(:message, inbox: inbox1) }
    let(:message4) { create(:message, outbox: outbox1) }
    let(:message5) { create(:message, outbox: outbox2) }
    let(:message6) { create(:message, outbox: outbox1) }

    context 'when box type is inbox' do
      let(:box_type) { :inbox }

      it 'returns messages', :aggregate_failures do
        expect(subject).to include(message1, message3)
        expect(subject).not_to include(message2)
      end
    end

    context 'when box type is outbox' do
      let(:box_type) { :outbox }

      it 'returns messages', :aggregate_failures do
        expect(subject).to include(message4, message6)
        expect(subject).not_to include(message5)
      end
    end
  end
end
