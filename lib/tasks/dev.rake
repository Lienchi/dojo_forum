namespace :dev do
  task fake_user: :environment do
    User.destroy_all

    User.create!(
      name: "admin", email: "admin@example.com", password: "12345678", role: "admin"
      )
    puts "Default admin created!"

    9.times do |i|
      user_name = FFaker::Name.first_name_female
      u = User.create!(email: "user#{i}@example.com", password: "12345678", name: "#{user_name}")
      u.avatar = Rails.root.join( "public/avatar/female/user#{i+1}.jpg").open
      u.save
    end

    9.times do |i|
      user_name = FFaker::Name.first_name_male
      u = User.create!(email: "user#{9+i}@example.com", password: "12345678", name: "#{user_name}")
      u.avatar = Rails.root.join( "public/avatar/male/user#{i+1}.jpg").open
      u.save
    end
    puts "now you have #{User.count} users data"
  end

end
