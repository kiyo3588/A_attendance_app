class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
  end

  def update_one_month
    errors = []
    
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)

        started_hour, started_min = extract_time_from(item[:started_at])        
        finished_hour, finished_min = extract_time_from(item[:finished_at])

        if started_hour.nil?
          item[:started_at] = nil
        else
          item[:started_at] = attendance.worked_on.to_time.change(hour: started_hour, min: started_min)
        end

        if finished_hour.nil?
          item[:finished_at] = nil
        else
          item[:finished_at] = attendance.worked_on.to_time.change(hour: finished_hour, min: finished_min)
        end

        if item[:started_at].present? && item[:finished_at].blank?
          errors << "#{attendance.worked_on}の退社時間が未入力です。"
        elsif item[:started_at].blank? && item[:finished_at].present?
          errors << "#{attendance.worked_on}の出社時間が未入力です。"
        else
          attendance.started_at = item[:started_at]
          attendance.finished_at = item[:finished_at]
          attendance.save!
        end
      end
    end
  
    if errors.empty?
      flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = errors.join("<br>").html_safe
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
    rescue => e
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      flash[:danger] = "エラー: #{e.message}"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
  end

  def extract_time_from(time_string)
    return [nil, nil] if time_string.blank?

    hour, minute = time_string.split(":").map(&:to_i)
    puts "Extracted time: #{[hour, minute]}"
    return hour, minute
end

  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
    end

    def extract_time_from(time_string)

      hour, minute = time_string.split(":").map(&:to_i)
      puts "Extracted time: #{[hour, minute]}"
      return hour, minute
    end
end
