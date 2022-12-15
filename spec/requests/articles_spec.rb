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

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidのユーザーが存在するとき" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }
      it "そのユーザーのレコードが取得できる", :aggregate_failures do
        subject
        # binding.pry
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 4
        expect(res.keys).to eq ["id", "title", "updated_at", "user"]
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
     end
    end

    context "指定したidのユーザーが存在しない時" do
      let(:article_id) { 99999 }
      it "ユーザーが見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
