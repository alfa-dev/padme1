class AddContentToPad < ActiveRecord::Migration
  def change
    add_column :pads, :content, :string
  end
end
