class AddApproverIdAndRequestTypeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approver_id, :integer
    add_column :attendances, :request_type, :string
  end
end
