# frozen_string_literal: true

class PaymentFailureError < StandardError
  def initialize(message = PAYMENT_FAILED)
    super(message)
  end
end
