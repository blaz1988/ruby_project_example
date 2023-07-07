# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrescriptionPaymentJob, type: :job do
  describe '#perform' do
    let(:subject) { described_class.perform_now(patient_id: patient.id, admin_id: admin.id) }
    let(:patient) { create(:user, :patient) }
    let(:admin) { create(:user, :admin) }
    let(:inbox) { create(:inbox, user: admin) }
    let(:outbox) { create(:outbox, user: patient) }

    before do
      inbox
      outbox
    end

    context 'when payment is successful' do
      it 'creates payment record' do
        expect { subject }.to change(Payment, :count).by(1)
      end
    end

    context 'when payment fails' do
      let(:fallback_message) { "There was an issue 'Payment failed!' with payment." }

      before do
        allow(PaymentProviderFactory.provider).to receive(:debit_card).and_raise(PaymentFailureError)
      end

      it 'handles the payment failure gracefully and creates a fallback message to notify the patient' do
        expect(CreateMessage).to receive(:new).with(body: fallback_message, sender: patient,
                                                    recipient: admin).and_call_original
        subject
      end
    end
  end
end
