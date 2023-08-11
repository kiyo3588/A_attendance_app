class DropOvertimeRequestsTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :overtime_requests
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end