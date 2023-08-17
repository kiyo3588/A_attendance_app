class OvertimeRequestsController < ApplicationController
  before_action :set_superiors, only: [:new, :update]

  def new
    @attendance = Attendance.new
  end

  def update
    @attendance = Attendance.find(params[:id]) 

    worked_on_datetime = @attendance.worked_on.to_datetime
    year = worked_on_datetime.year
    month = worked_on_datetime.month
    day = worked_on_datetime.day

    hour = params[:attendance]["overtime_end_at(4i)"].to_i
    minute = params[:attendance]["overtime_end_at(5i)"].to_i

    overtime_end_at = @attendance.worked_on.in_time_zone.change(hour: hour, min: minute)

    @attendance.overtime_end_at = overtime_end_at
    @attendance.assign_attributes(attendance_params)
    @attendance.overtime_status = 'pending'
    @attendance.request_type = 'overtime'
  
    if @attendance.save
      # 成功時の処理
      redirect_to user_path(current_user), notice: "残業申請が成功しました。"
    else
      # エラー時の処理
      render :edit, alert: "残業申請に失敗しました。"
    end
  end
  
  private

  def attendance_params
    params.require(:attendance).permit(:overtime_task, :approver_id, :request_type)
  end

  def set_superiors
    @superiors = User.where(superior: true).where.not(id: current_user.id)
  end
end
