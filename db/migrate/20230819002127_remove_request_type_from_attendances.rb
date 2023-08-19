class RemoveRequestTypeFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :request_type, :string
  end
end
