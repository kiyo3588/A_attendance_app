class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.integer :base_number, null: false
      t.string :base_name, null: false
      t.string :base_type, null: false, default: 0

      t.timestamps
    end

    add_index :bases, :base_number, unique: true
    add_index :bases, :base_name, unique: true
  end
end
