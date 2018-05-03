class CategoriesController < ApplicationController
  def show
    @categories = Category.all
    @category = Category.find(params[:id])

    public_posts = @category.tagged_posts.where(draft: false, permission: "public")

    if current_user
      friends_posts = @category.tagged_posts.where(draft: false, permission: "friends")
      private_posts = @category.tagged_posts.where(draft: false, permission: "private")

      posts_ids = []
      public_posts.each do |post|
        posts_ids.push(post.id)
      end
      friends_posts.each do |post|
        if current_user.friend?(post.user)
          posts_ids.push(post.id)
        end
      end
      private_posts.each do |post|
        if post.my_post?
          posts_ids.push(post.id)
        end
      end

      posts = @category.tagged_posts.where(id: posts_ids)
      @q = posts.ransack(params[:q])

    else #!current_user
      @q = public_posts.ransack(params[:q])
    end

    @posts = @q.result.order(id: :desc).page(params[:page]).per(20)
  end
end
