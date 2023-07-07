# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :request do
  describe 'GET #index' do
    before { create(:user, :patient) }

    it 'returns a successful response' do
      get messages_path
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    let(:message) { create(:message, inbox: inbox, outbox: outbox) }
    let(:patient) { create(:user, :patient) }
    let(:inbox) { create(:inbox, user: inbox_user, unread_messages: 5) }
    let(:outbox) { create(:outbox, user: outbox_user) }

    context 'when a doctor reads a message' do
      before do
        inbox_user
        outbox_user
        allow(User).to receive(:current).and_return(User.default_doctor)
      end

      let(:inbox_user) { create(:user, :doctor) }
      let(:outbox_user) { create(:user, :patient) }

      it 'returns a successful response and decrements number of unread messages' do
        get message_path(message)
        expect(inbox.reload.unread_messages).to eq(4)
        expect(response).to be_successful
      end
    end

    context 'when non-doctor reads a message' do
      let(:inbox_user) { create(:user, :doctor) }
      let(:outbox_user) { create(:user, :patient) }

      before do
        inbox_user
        outbox_user
      end

      it 'returns a successful response and does not decrement number of unread messages' do
        get message_path(message)
        expect(inbox.reload.unread_messages).to eq(5)
        expect(response).to be_successful
      end
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get new_message_path
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    let(:message_params) { { message: { body: message_body, parent_id: parent_message.id } } }
    let(:message_body) do
      'Thanks for your order. I will in touch shortly after reviewing your treatment application.'
    end
    let(:parent_message) { create(:message) }
    let(:admin) { create(:user, :admin) }
    let(:doctor) { create(:user, :doctor) }
    let(:doctor_inbox) { create(:inbox, user: doctor, unread_messages: 5) }
    let(:current_user) {  User.current }
    let(:last_message) {  Message.last }

    before do
      create(:inbox, user: admin)
      doctor_inbox
      create(:outbox, user: admin)
      create(:outbox, user: doctor)

      post messages_path, params: message_params
    end

    context 'when the message is successfully created' do
      it 'redirects to the created message with a success notice' do
        expect(response).to redirect_to(last_message)
        expect(flash[:notice]).to eq(MESSAGE_SUCCESS)
      end

      it 'creates a message with an unread status' do
        expect(last_message.read).to be_falsey
        expect(last_message.body).to eq(message_body)
      end

      it 'message is sent to the correct inbox and outbox after creation' do
        expect(last_message.inbox.user).to eq(doctor)
        expect(last_message.outbox.user).to eq(current_user)
      end

      context 'when a doctor is sent a message' do
        before do
          allow(User).to receive(:current).and_return(doctor)
        end

        it 'increments number of unread messages' do
          expect(doctor_inbox.reload.unread_messages).to eq(6)
        end
      end
    end

    context 'when an error occurs during message creation' do
      before do
        allow_any_instance_of(CreateMessage).to receive(:call).and_raise(ActiveRecord::RecordInvalid)
      end

      let(:message_body) { '' }

      it 'redirects to the new message page with an error message' do
        expect(response).to redirect_to(new_message_path)
        expect(flash[:error]).to eq("Validation failed: Body can't be blank")
      end
    end
  end

  describe 'GET #lost_prescription' do
    let(:last_message) { Message.last }
    let(:lost_prescription_message) { LOST_PRESCRIPTION_MESSAGE }
    let(:patient) { create(:user, :patient) }
    let(:admin) { create(:user, :admin) }
    let(:outbox) { create(:outbox, user: patient) }
    let(:inbox) { create(:inbox, user: admin) }

    before do
      allow(PrescriptionPaymentJob).to receive(:perform_later)
      outbox
      inbox
    end

    it 'enqueues PrescriptionPaymentJob' do
      expect(PrescriptionPaymentJob).to receive(:perform_later)
                                    .with(patient_id: User.current.id, admin_id: admin.id)
        .exactly(1).times
      get lost_prescription_path
    end

    it 'redirects to the created message with a success notice' do
      get lost_prescription_path

      expect(response).to redirect_to(Message.last)
      expect(flash[:notice]).to eq("#{MESSAGE_SUCCESS} #{PAYMENT_TRIGGERED}")
    end

    it 'creates admin message' do
      get lost_prescription_path

      expect(last_message.body).to eq(LOST_PRESCRIPTION_MESSAGE)
      expect(last_message.inbox.user).to eq(admin)
    end
  end
end
