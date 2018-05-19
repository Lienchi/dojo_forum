class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  before_create :generate_authentication_token
  after_create :set_user_name, :set_user_avatar

  mount_uploader :avatar, AvatarUploader

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :friendships, -> {where confirmed: true}, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :inverse_friendships, -> {where confirmed: true}, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user
  has_many :inviting_friendships, -> {where confirmed: false}, class_name: "Friendship", dependent: :destroy
  has_many :inviting_friends, through: :inviting_friendships, source: :friend
  has_many :unconfirmed_friendships, -> {where confirmed: false}, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :unconfirmed_friends, through: :unconfirmed_friendships, source: :user

  has_many :collects, dependent: :destroy
  has_many :collected_posts, through: :collects, source: :post

  def admin?
    self.role == "admin"
  end

  def friend?(user)
    self.friends.include?(user) || self.inverse_friends.include?(user)
  end

  def inviting?(user)
    self.inviting_friends.include?(user)
  end

  def generate_authentication_token
     self.authentication_token = Devise.friendly_token
  end

  def set_user_name
    if !self.name
      user_name = self.email.split("@").first
      self.update(name: user_name)
    end
  end

  def set_user_avatar
    if !self.avatar.url
      default_user_image = File.open("#{Rails.root}/public/avatar/default-user-image.png")
      self.update(avatar: default_user_image)
    end
  end

  def self.from_omniauth(auth)
    # Case 1: Find existing user by facebook uid
    user = User.find_by_fb_uid( auth.uid )
    if user
      user.fb_token = auth.credentials.token
      user.save!
      return user
    end

    # Case 2: Find existing user by email
    existing_user = User.find_by_email( auth.info.email )
    if existing_user
      existing_user.fb_uid = auth.uid
      existing_user.fb_token = auth.credentials.token
      existing_user.save!
      return existing_user
    end

    # Case 3: Create new password
    user = User.new
    user.fb_uid = auth.uid
    user.fb_token = auth.credentials.token
    user.email = auth.info.email
    user.password = Devise.friendly_token[0,20]
    user.save!
    return user
  end
end
