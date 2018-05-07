class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :collect, :uncollect]
  impressionist :actions => [:show]

  def index
    if params[:category_id]
      @category = Category.find(params[:category_id])
      public_posts = @category.tagged_posts.where(draft: false, permission: "public")
    else
      public_posts = Post.where(draft: false, permission: "public")
    end

    friends_posts = []
    private_posts = []
    if current_user
      if params[:category_id]
        friends_posts = @category.tagged_posts.where(draft: false, permission: "friends")
        private_posts = @category.tagged_posts.where(draft: false, permission: "private")
      else
        friends_posts = Post.where(draft: false, permission: "friends")
        private_posts = Post.where(draft: false, permission: "private")
      end
    end

    posts_ids = get_posts_ids(public_posts, friends_posts, private_posts)
    posts = Post.where(id: posts_ids)
    @q = posts.ransack(params[:q])

    @posts = @q.result.order(id: :asc).page(params[:page]).per(20)
    @categories = Category.all
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user

    if params[:commit] == "Submit"
      @post.draft = false
    end

    if @post.save
      tagged_category_ids = @post.tagged_category_ids.split(",")
      Tag.create!(post_id: @post, category_id: tagged_category_ids)

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
  end

  def uncollect
    collects = Collect.where(post: @post, user: current_user)
    collects.destroy_all
  end




  private


  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :permission, :tagged_category_ids=>[])
  end

  
end
