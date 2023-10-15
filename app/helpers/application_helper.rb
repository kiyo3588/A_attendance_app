module ApplicationHelper

  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end

  def day_color_class(wday)
    case wday
    when 6 # 土曜日
      "text-blue"
    when 0 # 日曜日
      "text-red"
    else
      ""
    end
  end

  def format_time_hours(time, next_day_check=false) #翌日チェック○○時表記
    return unless time

    format_string = next_day_check ? "(翌日) %-H" : "%-H"
    time.strftime(format_string)
  end

  def format_time(time, next_day_check=false) #翌日チェック○○時○○分表記
    return unless time

    format_string = next_day_check ? "(翌日) %-H:%M" : "%-H:%M"
    time.strftime(format_string)
  end

  def same_day?(start_time, worked_on) #翌日チェックでも同日の場合　
    return unless  start_time && worked_on
    start_time.to_date == worked_on.to_date
  end
end