require 'rails_helper'

describe MailSweeper::EmailBlacklist do
  describe  "::permanent_block!" do
    subject { described_class.permanent_block!(email) }

    let(:email) { 'good@email.com'}

    context "with exists email" do
      let!(:modifier) { 2 }
      let!(:email_blacklist) { MailSweeper::EmailBlacklist.block!(email) }

      it 'blocks email permanently' do
        expect(subject.blocked).to be_truthy
        expect(subject.blocked_until).to be_nil
      end

      it 'increases the block counter' do
        expect {
          subject
        }.to change {
          email_blacklist.reload
          email_blacklist.block_counter
        }.by(1)
      end
    end

    context "with not exists email" do
      let!(:modifier) { 1 }

      it 'blocks email until the date based on modifier' do
        expect(subject.blocked).to be_truthy
        expect(subject.blocked_until).to be_nil
      end
    end
  end

  describe  "::block!" do
    subject { described_class.block!(email) }

    let(:email) { 'good@email.com'}
    let(:curret_time) { Time.parse('01.01.01 00:00 +0000') }

    before { allow(Time).to receive(:now).and_return(curret_time) }

    context "with exists email" do
      let!(:modifier) { 2 }
      let!(:email_blacklist) { MailSweeper::EmailBlacklist.block!(email) }

      it 'blocks email until the date based on modifier' do
        expect(subject.blocked).to be_truthy
        expect(subject.blocked_until).to eq(curret_time + modifier * 4.weeks)
      end

      it 'increases the block counter' do
        expect {
          subject
        }.to change {
          email_blacklist.reload
          email_blacklist.block_counter
        }.by(1)
      end
    end

    context "with not exists email" do
      let!(:modifier) { 1 }

      it 'blocks email until the date based on modifier' do
        expect(subject.blocked).to be_truthy
        expect(subject.blocked_until).to eq(curret_time + modifier * 4.weeks)
      end
    end
  end

  describe  "::unblock!" do
    subject { described_class.unblock!(email) }

    let(:email) { 'good@email.com'}
    let(:curret_time) { Time.parse('01.01.01 00:00 +0000') }

    before { allow(Time).to receive(:now).and_return(curret_time) }

    context "with exists email" do
      let!(:email_blacklist) { MailSweeper::EmailBlacklist.block!(email) }

      it 'unblocks email' do
        expect(subject.blocked_until).to be_nil
        expect(subject.blocked).to be_falsey
      end
    end

    context "with not exists email" do
      it 'raises an record not found error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe  "::blocked?" do
    subject { described_class.blocked?(email) }

    context "with exists email" do
      let(:email) { 'good@email.com'}

      context "with blocked email" do
        before { MailSweeper::EmailBlacklist.block!(email) }

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context "with unblocked email" do
        before do
          item = MailSweeper::EmailBlacklist.block!(email)
          item.unblock!
        end

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end
    end

    context "with not exists email" do
      let(:email) { 'fake@email.com'}

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end
end
