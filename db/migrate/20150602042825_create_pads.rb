class CreatePads < ActiveRecord::Migration
  def change
    create_table :pads do |t|

      t.timestamps
    end
  end
end
