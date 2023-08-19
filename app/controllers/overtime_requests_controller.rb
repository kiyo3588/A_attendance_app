class OvertimeRequestsController < ApplicationController
  before_action :set_superiors, only: [:new, :update]

  def new
    @attendance = Attendance.new
  end

  def update
    @attendance = Attendance.find(params[:id]) 

    worked_on_datetime = @attendance.worked_on.in_time_zone('Asia/Tokyo').to_datetime
    year = worked_on_datetime.year
    month = worked_on_datetime.month
    day = worked_on_datetime.day
    @attendance.assign_attributes(attendance_params)
    
    if params[:attendance][:next_day].to_i == 1
      @attendance.next_day = true
      worked_on_datetime = worked_on_datetime.advance(days: 1)
    else
      @attendance.next_day = false
    end

    hour = params[:attendance]["overtime_end_at(4i)"].to_i
    minute = params[:attendance]["overtime_end_at(5i)"].to_i

    overtime_end_at = worked_on_datetime.change(hour: hour, min: minute)

    @attendance.overtime_end_at = overtime_end_at
    @attendance.overtime_pending!
  
    if @attendance.save
      # 成功時の処理
      flash[:success] =  "残業申請が成功しました。"
      redirect_to user_path(current_user)
    else
      # エラー時の処理
      flash[:danger] =  "残業申請に失敗しました。"
      render :edit
    end
  end
  
  private

  def attendance_params
    params.require(:attendance).permit(:worked_on, :overtime_task, :approver_id, :overtime_end_at, :next_day)
  end

  def set_superiors
    @superiors = User.where(superior: true).where.not(id: current_user.id)
  end
end
