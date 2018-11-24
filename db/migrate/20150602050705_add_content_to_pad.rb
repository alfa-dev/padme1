class AddContentToPad < ActiveRecord::Migration[5.0]
  def change
    add_column :pads, :content, :string
  end
end
