class Category < ApplicationRecord
  has_many :tags, dependent: :destroy
  has_many :tagged_posts, through: :tags, source: :post
end
