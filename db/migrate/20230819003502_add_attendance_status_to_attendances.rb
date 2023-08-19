class AddAttendanceStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_status, :integer, default: 0
  end
end
