require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    # let!(:article) { create(:article) }
    it "記事の一覧が取得できる", :aggregate_failures do
      create(:article)
      # binding.pry
      subject
      # binding.pry
      res = JSON.parse(response.body)
      expect(res.length).to eq 1
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(response).to have_http_status(:ok)
    end
  end
end
