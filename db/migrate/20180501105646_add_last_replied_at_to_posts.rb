class AddLastRepliedAtToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :last_replied_at, :datetime, :default => nil
  end
end
