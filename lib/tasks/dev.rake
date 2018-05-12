namespace :dev do
  task fake_user: :environment do
    User.destroy_all

    file = File.open("#{Rails.root}/public/avatar/male/user10.jpg")
    User.create!(
      name: "admin",
      email: "admin@example.com",
      password: "12345678",
      role: "admin",
      avatar: file
    )
    puts "Default admin created!"

    9.times do |i|
      user_name = FFaker::Name.first_name_female
      file = File.open("#{Rails.root}/public/avatar/female/user#{i+1}.jpg")

      user = User.new(
        name: user_name,
        email: "user#{i}@example.com",
        password: "12345678",
        role: "normal",
        intro: FFaker::Lorem::sentence(30),
        avatar: file
      )

      user.save!
      puts user.name
    end

    9.times do |i|
      user_name = FFaker::Name.first_name_male
      file = File.open("#{Rails.root}/public/avatar/male/user#{i+1}.jpg")

      user = User.new(
        name: user_name,
        email: "user#{i+9}@example.com",
        password: "12345678",
        role: "normal",
        intro: FFaker::Lorem::sentence(30),
        avatar: file
      )

      user.save!
      puts user.name
    end
    puts "now you have #{User.count} users data"
  end

  task fake_post: :environment do
    post_permission_list = [
      "public",
      "friends",
      "private"
    ]

    Post.destroy_all

    100.times do |i|
      Post.create!(
        title: FFaker::Lorem.phrase,
        content: FFaker::Tweet.body,
        user: User.all.sample,
        draft: false,
        permission: post_permission_list.sample
      )
    end
    puts "have created fake posts!"

    30.times do |i|
      Post.create!(
        title: FFaker::Lorem.phrase,
        content: FFaker::Tweet.body,
        user: User.all.sample,
        draft: true
      )
    end
    puts "have created fake drafts!"
  end

  task fake_comment: :environment do
    Comment.destroy_all

    Post.all.each do |post|
      if post.draft == false
        5.times do |i|
          post.comments.create!(
            content: FFaker::Lorem.paragraph,
            user: User.all.sample
          )
        end
        post.update(last_replied_at: post.comments.order(updated_at: :desc).first.updated_at)
      end
    end
    puts "have created fake comments!"
    puts "now you have #{Comment.count} comments data!"
  end

  task fake_tag: :environment do
    Post.all.each do |post|
      Category.all.sample(rand(0..3)).each do |category|
        Tag.create!(post_id: post.id, category_id: category.id)
      end
    end
    puts "have created fake tags!"
    puts "now you have #{Tag.count} tags data!"
  end

  task set_role: :environment do
    User.all.each do |user|
      if user.role == nil
        user.update(role: "normal")
      end
    end
  end

  task update_user_replies_count: :environment do
    User.all.each do |user|
      User.update_counters user.id, :replies_count => user.comments.count
    end
  end
end