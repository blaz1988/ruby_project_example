# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DecrementDoctorsMessages do
  subject { described_class.call(current_user: current_user) }

  let(:doctor) { create(:user, :doctor) }
  let(:non_doctor) { create(:user, :patient) }
  let(:inbox) { create(:inbox, user: doctor, unread_messages: 5) }

  describe '#call' do
    context 'when the current_user is a doctor' do
      let(:current_user) { doctor }

      it 'decrements the doctor\'s messages count' do
        expect { subject }.to change { inbox.reload.unread_messages }.by(-1)
      end
    end

    context 'when the current_user is not a doctor' do
      let(:current_user) { non_doctor }

      it 'raises an error' do
        expect { subject }.to raise_error(RuntimeError, 'Recipient is not a doctor!')
      end
    end
  end
end
