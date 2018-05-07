class FeedsController < ApplicationController
  def index
    @users_count = User.count
    @posts_count = Post.count
    @comments_count = Comment.count

    # --- get chatterbox
    @chatterbox = User.order(replies_count: :desc).limit(10)
    
    # --- get most popular posts
    public_posts = Post.where(draft: false, permission: "public")

    friends_posts = []
    private_posts = []
    if current_user
      friends_posts = Post.where(draft: false, permission: "friends")
      private_posts = Post.where(draft: false, permission: "private")
    end

    posts_ids = get_posts_ids(public_posts, friends_posts, private_posts)
    posts = Post.where(id: posts_ids)
    @q = posts.ransack(replies_count: :asc)

    @popular_posts = @q.result.limit(10)
  end
end
