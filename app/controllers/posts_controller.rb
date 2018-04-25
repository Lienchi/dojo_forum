class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @posts = Post.page(params[:page]).per(10)
  end
end
