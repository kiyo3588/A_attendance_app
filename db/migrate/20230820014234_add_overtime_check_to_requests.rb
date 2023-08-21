class AddOvertimeCheckToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_check, :boolean
  end
end
