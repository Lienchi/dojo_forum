class Api::V1::PostsController < ApiController
  protect_from_forgery prepend: true
  before_action :authenticate_user!, except: :index
  
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find_by(id: params[:id])
    if !@post
      render json: {
        message: "Can't find the post!",
        status: 400
      }
    else
      render "api/v1/posts/show"
    end
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      render json: {
        message: "Photo created successfully!",
        result: @post
      }
    else
      render json: {
        errors: @post.errors
      }
    end
  end

  def update
    @post = Post.find_by(id: params[:id])
    if @post.update(post_params)
      render json: {
        message: "Post updated successfully!",
        result: @post
      }
    else
      render json: {
        errors: @post.errors
      }
    end
  end

  def destroy
    @post = Post.find_by(id: params[:id])
    @post.destroy
    render json: {
      message: "Post destroy successfully!"
    }
  end


  private

  def post_params
    params.permit(:title, :content, :permission, :draft, :image, :tagged_category_ids=>[])
  end
end
