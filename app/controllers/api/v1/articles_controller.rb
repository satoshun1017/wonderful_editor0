module Api::V1
  class ArticlesController < BaseApiController
    def index
      # ここのarticleで作成してあげる？
      # ここからarticles_specに飛ぶはず
      articles = Article.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end
  end
end
