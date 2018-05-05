class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin

  def index
    @users = User.all
  end

  def update
    @user = User.find(params[:id])
    if @user.update(role: params[:role])
      flash[:notice] = "user role was successfully updated"
      redirect_to admin_users_path
    else
      @users = User.all
      render :index
    end
  end

  private

  def user_params
    params.require(:user).permit(:role)
  end
end
