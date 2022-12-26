require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "必要な情報があるとき" do
      let(:params) { attributes_for(:user) }
      it "新規登録ができる", :aggregate_failures do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "success"
        # binding.pry
      end
    end

    context "nameがない時" do
      let(:params) { attributes_for(:user, name: nil) }
      it "エラーする", :aggregate_failures do
        # binding.pry
        # subject
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        # binding.pry
        expect(res["errors"]["name"]).to eq ["can't be blank"]
      end
    end

    context "emailがない時" do
      let(:params) { attributes_for(:user, email: nil) }
      it "エラーする", :aggregate_failures do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        # binding.pry
        expect(res["errors"]["email"]).to eq ["can't be blank"]
      end
    end

    context "emailがない時" do
      let(:params) { attributes_for(:user, password: nil) }
      it "エラーする", :aggregate_failures do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["password"]).to eq ["can't be blank"]
      end
    end
  end
end
