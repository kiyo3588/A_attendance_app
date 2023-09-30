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
end