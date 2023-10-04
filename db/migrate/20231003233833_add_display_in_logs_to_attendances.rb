class AddDisplayInLogsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :display_in_logs, :boolean
  end
end
