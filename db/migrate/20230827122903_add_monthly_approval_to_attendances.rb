class AddMonthlyApprovalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_approval_status, :integer, default: 0
    add_column :attendances, :monthly_approval_approver_id, :integer
    add_column :attendances, :attendance_approver_id, :integer
  end
end
