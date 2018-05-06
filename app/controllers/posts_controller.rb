class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :collect, :uncollect]
  impressionist :actions => [:show]

  def index
    public_posts = Post.where(draft: false, permission: "public")

    if current_user
      friends_posts = Post.where(draft: false, permission: "friends")
      private_posts = Post.where(draft: false, permission: "private")

      posts_ids = []
      public_posts.each do |post|
        posts_ids.push(post.id)
      end
      friends_posts.each do |post|
        if current_user.friend?(post.user) || current_user == post.user
          posts_ids.push(post.id)
        end
      end
      private_posts.each do |post|
        if post.my_post?
          posts_ids.push(post.id)
        end
      end

      posts = Post.where(id: posts_ids)
      @q = posts.ransack(params[:q])

    else #!current_user
      @q = public_posts.ransack(params[:q])
    end

    @posts = @q.result.order(id: :asc).page(params[:page]).per(20)
    @categories = Category.all
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
    @viewed_count = @post.impressionist_count
    @post.update(viewed_count: @viewed_count)
    @comments = @post.comments.page(params[:page]).per(20)
    @comment = Comment.new
  end

  def update
    if @post.update(post_params)
      #redirect_to post_path(@post)
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
