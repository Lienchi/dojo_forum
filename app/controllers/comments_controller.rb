class CommentsController < ApplicationController
  before_action :set_post, only: [:create, :edit, :update, :destroy]
  before_action :set_comment, only: [:edit, :update, :destroy]
  after_action :update_last_replied_at, only: [:create, :update, :destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    @comment.save!
    redirect_to post_path(@post)
  end

  def edit
    if @comment.user != current_user
      redirect_to post_path(@post)
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post)
      flash[:notice] = "comment was successfully updated"
    else
      render :edit
      flash[:notice] = "comment was failed to update"
    end
  end

  def destroy
    if current_user.admin? || current_user == @comment.user
      @comment.destroy
      redirect_to post_path(@post)
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def update_last_replied_at
    if !@post.comments.empty?
      @post.update(last_replied_at: @post.comments.order(updated_at: :desc).first.updated_at)
    end
  end
end
