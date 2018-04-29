class Post < ApplicationRecord
  validates_presence_of :title, :content
  is_impressionable

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :tags, dependent: :destroy
end
