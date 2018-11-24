class AddNameToPad < ActiveRecord::Migration[5.0]
  def change
    add_column :pads, :name, :string
  end
end
