# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateMessage do
  let(:subject) { described_class.call(body: message_body, sender: patient, recipient: doctor) }

  let(:patient) { create(:user, :patient) }
  let(:doctor) { create(:user, :doctor) }

  before do
    create(:outbox, user: patient)
    create(:outbox, user: doctor)
    create(:inbox, user: patient)
    create(:inbox, user: doctor)
  end

  describe '#call' do
    context 'when message is valid' do
      let(:message_body) {
        'Thanks for your order. I will in touch shortly after reviewing your treatment application.'
      }

      it 'saves message with unread status and sends to the recipient inbox', :aggregate_failures do
        expect { subject }.to change(Message, :count).by(1)
        expect(subject.read).to be_falsey
        expect(subject.outbox_id).to eq(patient.outbox.id)
        expect(subject.inbox_id).to eq(doctor.inbox.id)
      end
    end

    context 'when message is invalid' do
      let(:message_body) { '' }

      it 'raises a validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
