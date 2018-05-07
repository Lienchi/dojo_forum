class Comment < ApplicationRecord
  belongs_to :user, counter_cache: :replies_count
  belongs_to :post, counter_cache: :replies_count
end
