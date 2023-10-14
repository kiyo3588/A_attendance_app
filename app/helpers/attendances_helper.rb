module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end

  def format_time(time, next_day_check=false)
    return unless time

    format_string = next_day_check ? "(翌日) %-H:%M" : "%-H:%M"
    time.strftime(format_string)
  end

  def same_day?(start_time, end_time)
    return unless start_time && end_time
    start_time.to_date == end_time.to_date
  end
end
