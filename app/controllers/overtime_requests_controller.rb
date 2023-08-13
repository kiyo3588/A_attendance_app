class OvertimeRequestsController < ApplicationController
  before_action :set_superiors, only: [:update]

  def update
    @attendance = Attendance.find(params[:id])
  
     # 終了予定時間を組み合わせてDateTimeオブジェクトを作成
     end_hour = params[:attendance][:end_hour].to_i
     end_minute = params[:attendance][:end_minute].to_i
     date = @attendance.worked_on
  
    # 翌日の場合、時間を1日追加
    if params[:attendance][:next_day] == "1"
      date += 1.day
    end

    @attendance.overtime_end_at = date.change(hour: end_hour, min: end_minute)
  
    if @attendance.update(attendance_params)
      # 成功時の処理
      redirect_to "#", notice: "残業申請が成功しました。"
    else
      # エラー時の処理
      render :edit, alert: "残業申請に失敗しました。"
    end
  end
  
  private
  
  def attendance_params
    params.require(:attendance).permit(:overtime_task, :instructor_confirmation)
  end

  def set_superiors
    @superiors = User.where(superior: true).where.not(id: current_user.id)
  end
end
