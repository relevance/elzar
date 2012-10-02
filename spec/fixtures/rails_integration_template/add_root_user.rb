class AddRootUser < ActiveRecord::Migration
  def up
    User.find_or_create_by_username! 'root'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
