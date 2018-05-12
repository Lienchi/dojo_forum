class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :comments, :collects, :drafts, :friends]

  def show
    @posts = @user.posts.where(draft: false).page(params[:page]).per(10)
  end

  def edit
    unless @user == current_user
      redirect_to user_path(@user)
    end
  end

  def update
    @user.update(user_params)
    redirect_to user_path(@user)
  end

  def comments
    @comments = @user.comments.page(params[:page]).per(10)
  end

  def collects
    @collects = @user.collected_posts.page(params[:page]).per(10)
  end

  def drafts
    if @user == current_user
      @drafts = current_user.posts.where(draft: true).page(params[:page]).per(10)
    end
  end

  def friends
    @friends = current_user.friends + current_user.inverse_friends
    @inviting_friends = current_user.inviting_friends
    @unconfirmed_friends = current_user.unconfirmed_friends
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :intro, :avatar)
  end
end
