class AddDetailsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :string
    add_column :users, :uid, :string
    add_column :users, :designated_work_start_time, :datetime, default: Time.current.change(hour: 9, min: 00, sec: 0)
    add_column :users, :designated_work_end_time, :datetime, default: Time.current.change(hour: 18, min: 00, sec: 0)
  end
end
