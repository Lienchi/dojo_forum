class Post < ApplicationRecord
  validates_presence_of :title, :content
  is_impressionable

  mount_uploader :image, PhotoUploader

  belongs_to :user
  has_many :comments, dependent: :destroy

  has_many :tags, dependent: :destroy
  has_many :tagged_categories, through: :tags, source: :category

  has_many :collects, dependent: :destroy
  has_many :collected_users, through: :collects, source: :user

  def collected?(user)
    self.collected_users.include?(user)
  end
end
