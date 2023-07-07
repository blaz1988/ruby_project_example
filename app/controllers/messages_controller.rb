# frozen_string_literal: true

class MessagesController < ApplicationController
  def index
    @messages = ReadMessages.call(user: current_user, box_type: params[:box_type] || :inbox)
    @messages = @messages.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def show
    @message = ReadMessage.call(message_id: params[:id], current_user_id: current_user.id)
    DecrementDoctorsMessages.call(current_user: current_user) if current_user.is_doctor?
  end

  def new
    @message = Message.new
  end

  def create
    recipient = FindRecipient.call(parent_message_id: message_params[:parent_id], doctor: default_doctor,
                                   admin: default_admin)
    message = CreateMessage.call(body: message_params[:body], sender: current_user, recipient: recipient)

    redirect_to message, notice: MESSAGE_SUCCESS
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    redirect_to new_message_path
  end

  def lost_prescription
    PrescriptionPaymentJob.perform_later(patient_id: current_user.id, admin_id: default_admin.id)
    message = CreateMessage.call(body: LOST_PRESCRIPTION_MESSAGE, sender: current_user, recipient: default_admin)

    redirect_to message, notice: "#{MESSAGE_SUCCESS} #{PAYMENT_TRIGGERED}"
  end

  private

  def message_params
    params.require(:message).permit(:body, :parent_id)
  end

  def current_user
    @current_user ||= User.current
  end

  def default_admin
    @default_admin ||= User.default_admin
  end

  def default_doctor
    @default_doctor ||= User.default_doctor
  end
end
