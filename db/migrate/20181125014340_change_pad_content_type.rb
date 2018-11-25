class ChangePadContentType < ActiveRecord::Migration[5.2]
  def change
    change_column :pads, :content, :text
  end
end
