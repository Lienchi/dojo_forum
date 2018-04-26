class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @posts = Post.page(params[:page]).per(10)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      flash[:notice] = "post was successfully created"
      redirect_to root_path
    else
      flash[:alert] = "post was failed to create"
      render :new
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
