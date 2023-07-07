# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindRecipient do
  subject { described_class.call(parent_message_id: parent_message_id, doctor: doctor, admin: admin) }

  let(:parent_message) { create(:message, created_at: created_at) }
  let(:parent_message_id) { parent_message.id }
  let(:doctor) { create(:user, :doctor) }
  let(:admin) { create(:user, :admin) }

  describe '#call' do
    context 'when parent message is defined' do
      context 'when parent message is created more than a week ago' do
        let(:created_at) { 2.weeks.ago }

        it 'returns the admin as the recipient' do
          expect(subject).to eq(admin)
        end
      end

      context 'when parent message is created within a week' do
        let(:created_at) { 2.days.ago }

        it 'returns the doctor as the recipient' do
          expect(subject).to eq(doctor)
        end
      end
    end

    context 'when parent message is not defined' do
      let(:parent_message_id) { 0 }
      let(:created_at) { 2.weeks.ago }

      it 'raises an error' do
        expect { subject }.to raise_error(RuntimeError, 'Parent message is not defined!')
      end
    end
  end
end
