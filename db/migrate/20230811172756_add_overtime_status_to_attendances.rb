class AddOvertimeStatusToAttendances < ActiveRecord::Migration[5.1]
  def up
    # integer型のカラムを追加（まだコミットしない）
    add_column :attendances, :overtime_status_int, :integer, default: 0

    # 既存のstringデータをintegerに変換
    Attendance.all.each do |attendance|
      # ここでの変換ロジックは、実際のstringデータに応じて適宜調整してください。
      status_mapping = {
        "なし" => 0,
        "申請中" => 1,
        "承認" => 2,
        "否認" => 3
      }
      attendance.update_column(:overtime_status_int, status_mapping[attendance.overtime_status])
    end

    # string型のカラムを削除
    remove_column :attendances, :overtime_status

    # integer型のカラム名を変更
    rename_column :attendances, :overtime_status_int, :overtime_status
  end

  def down
    # ロールバック時の処理（必要に応じて実装）
    add_column :attendances, :overtime_status_string, :string

    # 他の変更を元に戻す
    rename_column :attendances, :overtime_status, :overtime_status_int
    remove_column :attendances, :overtime_status_int

    # データ変換のロールバックも必要であれば実装してください。
  end
end
