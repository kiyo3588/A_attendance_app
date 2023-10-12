class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :approved_logs]
  before_action :logged_in_user, only: [:update, :edit_one_month, :approved_logs]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  before_action :set_superiors, only: [:edit_one_month, :update_one_month]

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
    
    begin
      ActiveRecord::Base.transaction do
        attendances_params.each do |id, item|
          @attendance = Attendance.find(id)
          # next if item[:attendance_approver_id].blank?
          worked_on_datetime = @attendance.worked_on.in_time_zone('Asia/Tokyo').to_datetime
      
          started_hour, started_min = extract_time_from(item[:started_at])
          finished_hour, finished_min = extract_time_from(item[:finished_at])

          if started_hour.nil?
            item[:started_at] = nil
          else
            item[:started_at] = worked_on_datetime.change(hour: started_hour, min: started_min)
          end

          if finished_hour.nil?
            item[:finished_at] = nil
          else
            item[:finished_at] = worked_on_datetime.change(hour: finished_hour, min: finished_min)
          end

          if item[:next_day].to_i == 1
            @attendance.next_day = true
            worked_on_datetime = worked_on_datetime.advance(days: 1)

            if item[:finished_at].present?
              item[:finished_at] = worked_on_datetime.change(hour: finished_hour, min: finished_min)
            end
          else
            @attendance.next_day = false
          end

          if item[:started_at].present? && item[:finished_at].blank?
            errors << "#{@attendance.worked_on}の退社時間が未入力です。"
          elsif item[:started_at].blank? && item[:finished_at].present?
            errors << "#{@attendance.worked_on}の出社時間が未入力です。"
          else
            
            if @attendance.attendance_approver_id.blank?

            else
              
              # 送信された値（これはフォームから送信されたパラメータを取得する例です。実際の値に置き換えてください）
              new_started_at = item[:started_at]
              new_finished_at = item[:finished_at]

              # 編集前の時間と送信された時間が同じであるかどうかをチェック
              if @attendance.started_at == new_started_at && @attendance.finished_at == new_finished_at
              
              else
                @attendance.started_at = item[:started_at]
                @attendance.finished_at = item[:finished_at]
                @attendance.note = item[:note]
                @attendance.attendance_approver_id = item[:attendance_approver_id]

                @attendance.attendance_pending!
              end
            
              @attendance.save!
            end
          end
        end
      end

    rescue => e
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      flash[:danger] << "エラー: #{e.message}"
    end
  
    if errors.empty?
      flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = errors.join("<br>").html_safe
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
  end

  def update_attendance_request
    success = false # フラグを用意して、更新が成功したかどうかを追跡

    params[:attendance_requests].each do |id, attendance_params|
      attendance = Attendance.find(id)

      if attendance_params["approval_status"] == "1" && attendance_params["attendance_status"] == "attendance_approved"
        success = attendance.update(attendance_status: attendance_params["attendance_status"],
                                    display_in_logs: true)
      elsif attendance_params["approval_status"] == "1"
        success = attendance.update(attendance_status: attendance_params["attendance_status"])
      end
    end

    if success
      flash[:success] = '勤怠変更申請を更新しました。'
    else
      flash[:warning] = '勤怠変更申請の更新に問題がありました。'
    end

    redirect_to user_path(current_user)
  end

  def approved_logs
    if params[:search].present? && params[:search][:year].present? && params[:search][:month].present?
      if valid_year_month?(params[:search][:year], params[:search][:month])
        start_date = Date.new(params[:search][:year].to_i, params[:search][:month].to_i, 1)
        end_date = start_date.end_of_month
        @approved_attendances = Attendance.attendance_approved.where(user_id: params[:user_id],
                                                                   worked_on: start_date..end_date,
                                                                   display_in_logs: true)
      else
        @approved_attendances = Attendance.attendance_approved.where(user_id: params[:user_id],
                                                                    display_in_logs: true)
      end
    else
      @approved_attendances = Attendance.attendance_approved.where(user_id: params[:user_id],
                                                                  display_in_logs: true)
    end
  end

  def reset_approved_logs
    @user = User.find(params[:user_id]) # 対象のユーザーを見つける
    @user.attendances.where(display_in_logs: true).update_all(display_in_logs: false)  # そのユーザーの、表示すべき履歴ログを非表示にする
    flash[:success] = "履歴ログをリセットしました。"
    redirect_to approved_logs_user_attendance_path(@user)
  end
  
  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :next_day, :attendance_approver_id, :attendance_status, :approval_status])[:attendances]
    end

    # def update_one_month_params
    #   params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :attendance_status, :next_day, :attendance_approver_id])[:attendances]
    # end
    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end

    def extract_time_from(time_string)
      hour, minute = time_string.split(":").map(&:to_i)
      return hour, minute
    end

    def set_superiors
      @superiors = User.where(superior: true).where.not(id: current_user.id)
    end

    def valid_year_month?(year, month)
      (year.to_i.to_s == year) && (month.to_i.to_s == month) && (1..12).include?(month.to_i)
    end
end
