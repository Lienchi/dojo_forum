class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :collect, :uncollect]
  impressionist :actions => [:show]

  def index
    public_posts = Post.where(draft: false, permission: "public")

    if current_user
      friends_posts = Post.where(draft: false, permission: "friends")
      my_friends_posts = []
      friends_posts.each do |post|
        if current_user.friend?(post.user)
          my_friends_posts.push(post)
        end
      end

      @posts = Kaminari.paginate_array(public_posts+my_friends_posts).page(params[:page]).per(10)
    else
      @posts = public_posts.page(params[:page]).per(10)
    end
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
