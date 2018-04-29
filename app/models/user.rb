class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar, AvatarUploader

  has_many :posts
  has_many :comments

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
end
