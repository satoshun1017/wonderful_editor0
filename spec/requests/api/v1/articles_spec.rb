require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article) { create(:article, :published) }
    before { create(:article, :draft) }
    it "記事の一覧が取得できる", :aggregate_failures do
      # create(:article, :published)
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
      let(:article_id) { article.id }
      context "対象の記事が公開中の時" do
        let(:article) { create(:article, :published) }
      it "そのユーザーのレコードが取得できる", :aggregate_failures do
        subject
        # binding.pry
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 6
        expect(res.keys).to eq ["id", "title", "body", "status", "updated_at", "user"]
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
      end
     end
    end

    context "指定したidのユーザーが存在しない時" do
      let(:article_id) { 99999 }
      it "ユーザーが見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }
    let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }
    context "適切なパラメーターを送信したとき" do
      let(:params) { { article: attributes_for(:article, :published) } }
      # let(:current_user) { create(:user) }
      # let(:headers) { current_user.create_new_auth_token }
      # allow(実装を置き換えたいオブジェクト).to receive(置き換えたいメソッド名).and_return(返却したい値やオブジェクト)
      # before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

      it "ユーザーのレコードが作成できる", :aggregate_failures do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
      end
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article, :published) } }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    # before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "適切なパラメーターを受信した時" do
      let(:article) { create(:article, user: current_user) }
      it "ユーザーのレコードを更新できる" do
        # binding.pry
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body])
        # binding.pry
      end
    end

    context "自分の所持するユーザーでない時" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      it "更新できない" do
        # binding.pry
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:article_id) { article.id }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    # before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "自分が持っているものを削除しようとした時" do
      let!(:article) { create(:article, user: current_user) }
      it "任意のユーザーが削除できる" do
        # binding.pry
        expect { subject }.to change { Article.count }.by(-1)
      end
    end

    context "自分の持っていないもの" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      it "削除できない" do
        # binding.pry
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
