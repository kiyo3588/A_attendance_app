class RenameOvertimeCheckColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :overtime_check, :approval_status
  end
end