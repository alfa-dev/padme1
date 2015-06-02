class AddNameToPad < ActiveRecord::Migration
  def change
    add_column :pads, :name, :string
  end
end
