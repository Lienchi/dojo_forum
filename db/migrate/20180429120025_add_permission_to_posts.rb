class AddPermissionToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :permission, :string, :default => 'friends'
  end
end
