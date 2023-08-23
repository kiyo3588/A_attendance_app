class RenameApproverIdToOvertimeApproverId < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :approver_id, :overtime_approver_id
  end
end
