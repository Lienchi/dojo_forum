class ApplicationController < ActionController::Base
  
  private

  def authenticate_admin
    unless current_user.admin?
      flash[:alert] = "Not allow!"
      redirect_to root_path
    end
  end

  def get_posts_ids(public_posts, friends_posts, private_posts)
    posts_ids = []
    public_posts.each do |post|
      posts_ids.push(post.id)
    end
    if current_user
      friends_posts.each do |post|
        if current_user.friend?(post.user) || current_user == post.user
          posts_ids.push(post.id)
        end
      end
    end
    private_posts.each do |post|
      if post.my_post?
        posts_ids.push(post.id)
      end
    end

    return posts_ids
  end
end
