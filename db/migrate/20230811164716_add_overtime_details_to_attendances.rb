class AddOvertimeDetailsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_status, :string
    add_column :attendances, :overtime_end_at, :datetime
    add_column :attendances, :overtime_task, :string
  end
end
