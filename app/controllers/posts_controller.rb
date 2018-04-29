class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :collect, :uncollect]
  impressionist :actions => [:show]

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

  def show
    impressionist(@post)
  end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post)
      flash[:notice] = "post was successfully updated"
    else
      render :edit
      flash[:notice] = "post was failed to update"
    end
  end

  def destroy
    @post.destroy
    redirect_to root_path
  end

  def collect
    @post.collects.create!(user: current_user)
    redirect_back(fallback_location: root_path)
  end

  def uncollect
    collects = Collect.where(post: @post, user: current_user)
    collects.destroy_all
    redirect_back(fallback_location: root_path)
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
