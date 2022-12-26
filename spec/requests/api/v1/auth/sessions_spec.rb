require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "ユーザーの情報を入力した時" do
      let(:user) { create(:user) }
      let(:params) {  attributes_for(:user, email: user.email, password: user.password) }
      it "ログインできる", :aggregate_failures do
        subject
        # binding.pry
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "emailが一致しない時" do
      let(:user) { create(:user) }
      let(:params) {  attributes_for(:user, email: "hoge", password: user.password) }
      it "ログインできない", :aggregate_failures do
        subject
        # binding.pry
        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["expiry"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
      end
    end

    context "passwordが一致しない時" do
      let(:user) { create(:user) }
      let(:params) {  attributes_for(:user, email: user.email, password: "hoge") }
      it "ログインできない", :aggregate_failures do
        subject
        # binding.pry
        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["expiry"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_in" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    # subject { post(api_v1_user_session_path, params: params) }
    context "ログアウトする時" do
      let(:headers) { user.create_new_auth_token }
      let(:user) { create(:user) }
      it "ログアウトできる", :aggregate_failures do
        subject
        # binding.pry
        expect(response.status).to eq 200
      end
    end

    context "誤った情報を送信したとき" do
      let(:user) { create(:user) }
      let!(:headers) { { "access-token" => "", "token-type" => "", "client" => "", "expiry" => "", "uid" => "" } }

      it "ログアウトできない", :aggregate_failures do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
      end
    end
  end
end
