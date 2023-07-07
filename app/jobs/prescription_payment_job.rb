# frozen_string_literal: true

class PrescriptionPaymentJob < ApplicationJob
  queue_as :default

  def perform(patient_id:, admin_id:)
    patient = User.find(patient_id)
    admin = User.find(admin_id)
    PaymentProviderFactory.provider.debit_card(patient)
  rescue PaymentFailureError => e
    handle_payment_failure(patient, admin, e)
  end

  private

  def handle_payment_failure(patient, admin, error)
    fallback_message = "There was an issue '#{error}' with payment."
    CreateMessage.new(body: fallback_message, sender: patient, recipient: admin).call
  end
end
