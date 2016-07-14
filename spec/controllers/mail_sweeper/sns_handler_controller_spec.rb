require 'rails_helper'

describe MailSweeper::SnsHandlerController, type: :controller do
  routes { MailSweeper::Engine.routes }

  describe "POST sns" do
    context "with subcription notification" do
      let(:subscribe_url) { 'http://example.com' }
      let!(:notification) {
        {
          'Type' => 'SubscriptionConfirmation',
          'SubscribeURL' => subscribe_url
        }.to_json
      }

      before { stub_request(:get, subscribe_url) }

      it 'makes request to subscribe url' do
        post :sns, notification
        expect(WebMock).to have_requested(:get, subscribe_url)
      end
    end

    context "with notification" do
      let(:email) { 'example@example.com' }

      context "with soft bounce" do
        let!(:notification) {
          {
            'Type' => 'Notification',
            'Message' => {
              'notificationType' => 'Bounce',
              'bounce' => { 'bounceType' => 'Transient' },
              'mail' => { 'destination' => [email] }
            }.to_json
          }.to_json
        }

        it 'blocks email' do
          expect(
            MailSweeper::EmailBlacklist
          ).to receive(:block!).with(email)

          post :sns, notification
        end
      end

      context "with hard bounce" do
        let!(:notification) {
          {
            'Type' => 'Notification',
            'Message' => {
              'notificationType' => 'Bounce',
              'bounce' => { 'bounceType' => 'Permanent' },
              'mail' => { 'destination' => [email] }
            }.to_json
          }.to_json
        }

        it 'blocks email permanently' do
          expect(
            MailSweeper::EmailBlacklist
          ).to receive(:permanent_block!).with(email)

          post :sns, notification
        end
      end

      context "with complaint" do
        let!(:notification) {
          {
            'Type' => 'Notification',
            'Message' => {
              'notificationType' => 'Complaint',
              'mail' => { 'destination' => [email] }
            }.to_json
          }.to_json
        }

        it 'blocks email permanently' do
          expect(
            MailSweeper::EmailBlacklist
          ).to receive(:permanent_block!).with(email)

          post :sns, notification
        end
      end
    end
  end
end
