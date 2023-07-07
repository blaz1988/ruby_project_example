# frozen_string_literal: true

class Provider
  def debit_card(user)
    payment = Payment.new(user: user)

    raise PaymentFailureError, PAYMENT_FAILED unless payment.save
  end
end
