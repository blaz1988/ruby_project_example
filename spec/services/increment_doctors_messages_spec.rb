# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IncrementDoctorsMessages do
  subject { described_class.call(recipient: recipient) }

  let(:doctor) { create(:user, :doctor) }
  let(:non_doctor) { create(:user, :patient) }
  let(:inbox) { create(:inbox, user: doctor) }

  describe '#call' do
    context 'when the recipient is a doctor' do
      let(:recipient) { doctor }

      it 'increments the doctor\'s unread messages count' do
        expect { subject }.to change { inbox.reload.unread_messages }.by(1)
      end
    end

    context 'when the recipient is not a doctor' do
      let(:recipient) { non_doctor }

      it 'raises an error' do
        expect { subject }.to raise_error(RuntimeError, 'Recipient is not a doctor!')
      end
    end
  end
end
