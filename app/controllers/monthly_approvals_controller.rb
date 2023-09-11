class MonthlyApprovalsController < ApplicationController

  def show
    if params[:date]
      @first_day = Date.parse(params[:date]).beginning_of_month
    else
      @first_day = Date.current.beginning_of_month
    end
    
    @attendances = @user.attendances.where(worked_on: @first_day..@first_day.end_of_month).order(:worked_on)
    @worked_sum = @attendances.where.not(started_at: nil).count

    @unapproved_monthly_requests = current_user.attendances.monthly_approval_pending.where(worked_on: current_user.attendances.monthly_approval_pending.minimum(:worked_on)).count
    
    @monthly_approval_requests = Attendance.where(monthly_approval_approver_id: current_user.id, 
                                                  monthly_approval_status: "monthly_approval_pending")
                                          .group_by { |m| [m.user_id, m.worked_on.beginning_of_month] }
                                          .map { |key, values| values.find { |v| v.worked_on == key[1] } }

    # @unapproved_overtime_requests = Attendance.where(overtime_approver_id: @user.id, overtime_status: Attendance.overtime_statuses[:overtime_pending]).count
    # @overtime_requests = Attendance.where(overtime_approver_id: current_user.id, overtime_status: "overtime_pending")

    @superiors = User.where(superior: true).where.not(id: current_user.id)

    @monthly_approval_status = if @attendances.first&.monthly_approval_status.nil? || @attendances.first.monthly_approval_status == "monthly_approval_no_request"                   
                              "未"
                          elsif @attendances.first.monthly_approval_status == "monthly_approval_pending"
                            "申請中"
                          elsif  @attendances.first.monthly_approval_status == "monthly_approval_approved"
                            "承認済み"
                          elsif @attendances.first.monthly_approval_status == "monthly_approval_declined"
                          else
                            "その他のステータス"
                          end
                          
    approver_ids = @attendances.map(&:monthly_approval_approver_id).compact.uniq
    @monthly_approval_approvers = User.where(id: approver_ids)

    @grouped_monthly_approval_requests = @monthly_approval_requests.group_by(&:user)
  end

  def create
    if params[:superior_user_id].blank?
      flash[:danger] = "申請先を指定してください。"
      redirect_to user_path(current_user) and return
    end

    first_day = Date.parse(params[:first_day])
    monthly_attendance = current_user.attendances.find_or_initialize_by(worked_on: first_day)    # 月の初日のデータを取得または新規作成

    if monthly_attendance.update(monthly_approval_status: "monthly_approval_pending", monthly_approval_approver_id: params[:superior_user_id])
      flash[:success] = "月次勤怠申請をしました。"
      redirect_to user_path(current_user)
    else
      flash[:danger] = "月次勤怠申請に失敗しました。"
      render 'users/show'
    end
  end

  def update
    params[:monthly_requests].each do |id, monthly_request_params|
      attendance = Attendance.find(id)

      if monthly_request_params["overtime_check"] == "1"
        attendance.update(monthly_approval_status: monthly_request_params["monthly_approval_status"])
        
        flash[:success] = "所属長承認申請の変更を行いました。"
        redirect_to user_path(current_user)
      else
        redirect_to user_path(current_user)
      end
    end
  end

  def monthly_approval
    @attendance = Attendance.find_by(user_id: current_user.id, worked_on: Date.today)
  end
end

private

  def attendance_params
    params.require(:attendance).permit(:monthly_approval_status, :overtime_check)
  end