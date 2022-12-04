# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string
#  nickname               :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  context "必要な情報があるとき" do
    it "ユーザーが作成される" do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  context "nameがないとき" do
    it "ユーザーが作成できない" do
      user = build(:user, name: nil)
      expect(user).to be_invalid
      expect(user.errors.messages[:name]).to eq ["can't be blank"]
      # binding.pry
    end

    context "emailがないとき" do
      it "エラーする" do
        user = build(:user, email: nil)
        expect(user).to be_invalid
        expect(user.errors.messages[:email]).to eq ["can't be blank"]
        # binding.pry
      end
    end

    context "passwordがない時" do
      it "エラーする" do
        user = build(:user, password: nil)
        expect(user).to be_invalid
        expect(user.errors.messages[:password]).to eq ["can't be blank"]
        # binding.pry
      end
    end
  end
end
