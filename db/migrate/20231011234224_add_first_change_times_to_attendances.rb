class AddFirstChangeTimesToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :first_started_at_before_change, :datetime
    add_column :attendances, :first_finished_at_before_change, :datetime
  end
end
