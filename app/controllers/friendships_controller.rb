class FriendshipsController < ApplicationController
  def create
    @friendship = current_user.friendships.build(friend_id: params[:friend_id], confirmed: false)

    if @friendship.save
      flash[:notice] = "Successfully invited"
      redirect_back(fallback_location: root_path)
    else
      flash[:alert] = @friendship.errors.full_message.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    @friendship = current_user.unconfirmed_friendships.where(user_id: params[:id]).first
    @friendship.destroy
    flash[:alert] = "Skip invitation!"
    redirect_back(fallback_location: root_path)
  end

  def accept
    @friendship = current_user.unconfirmed_friendships.where(user_id: params[:id]).first
    @friendship.update(confirmed: true)

    flash[:notice] = "Accept invitation!"
    redirect_back(fallback_location: root_path)
  end
end
