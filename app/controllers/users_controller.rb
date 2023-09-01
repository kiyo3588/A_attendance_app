class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working_employees]
  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, :working_employees]
  before_action :set_one_month, only: :show
  before_action :set_superiors, only: [:show]

  def index
    @users = User.where(admin: false).paginate(page: params[:page])
  end

  def show
    if params[:date]
      @first_day = Date.parse(params[:date]).beginning_of_month
    else
      @first_day = Date.current.beginning_of_month
    end
    
    @attendances = @user.attendances.where(worked_on: @first_day..@first_day.end_of_month).order(:worked_on)
    @worked_sum = @attendances.where.not(started_at: nil).count

    @monthly_approval_requests = Attendance.where(monthly_approval_approver_id: current_user.id, 
                                                  monthly_approval_status: "monthly_approval_pending")
                                              .group_by { |m| [m.user_id, m.worked_on.beginning_of_month] }
                                              .map { |key, values| values.find { |v| v.worked_on == key[1] } }
    @unapproved_monthly_requests = Attendance.where(monthly_approval_approver_id: current_user.id, monthly_approval_status: "monthly_approval_pending")
                                              .where(worked_on: Attendance.where(monthly_approval_approver_id: current_user.id, monthly_approval_status: "monthly_approval_pending").minimum(:worked_on))
                                              .count || 0
    @overtime_requests = Attendance.where(overtime_approver_id: current_user.id, overtime_status: "overtime_pending")
    @unapproved_overtime_requests = Attendance.where(overtime_approver_id: @user.id, overtime_status: Attendance.overtime_statuses[:overtime_pending]).count || 0

    @superiors = User.where(superior: true).where.not(id: current_user.id)

    @monthly_approval_status = if @attendances.any? { |attendance| attendance.monthly_approval_status == "monthly_approval_pending" }
                            "申請中"
                          elsif @attendances.all? { |attendance| attendance.monthly_approval_status == "monthly_approval_no_request" }
                            "未"
                          elsif @attendances.any? { |attendance| attendance.monthly_approval_status == "monthly_approval_approved" }
                            "承認済み"
                          elsif @attendances.any? { |attendance| attendance.monthly_approval_status == "monthly_approval_declined" }
                            "否認"
                          else
                            "その他のステータス"
                          end
                          
    approver_ids = @attendances.map(&:monthly_approval_approver_id).compact.uniq
    @monthly_approval_approvers = User.where(id: approver_ids)

    @grouped_monthly_approval_requests = @monthly_approval_requests.group_by(&:user)
  end

  def new
    @user = User.new(user_params)
  end

  def create
    @user = User.new(user_params)
    set_designated_times_for_user(@user) if @user.designated_work_start_time.nil? && @user.designated_work_end_time.nil?
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      if params[:from] == 'user_list'
        redirect_to users_path
      else
      redirect_to @user
      end
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報は更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  def working_employees
    @working_employees = User.joins(:attendances).where(attendances: { worked_on: Date.current }).where.not(attendances: { started_at: nil }).where(attendances: { finished_at: nil })
  end

  def import
    User.import(params[:file])
    flash[:success] = "ユーザーを追加しました。"
    redirect_to users_path
  end

  def attendance_review
    # ここで該当ユーザーの勤怠データを取得します。
    @user = User.find(params[:id])
    
    # 勤怠データの取得や処理のロジックを記述します。
    # 例: 1か月分の勤怠データの取得
    if params[:date]
      @first_day = Date.parse(params[:date]).beginning_of_month
    else
      @first_day = Date.current.beginning_of_month
    end
    
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(worked_on: @first_day..@first_day.end_of_month).order(:worked_on)
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end

    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_work_time, :work_time)
    end

    def set_superiors
      @superiors = User.where(superior: true).where.not(id: current_user.id)
    end

    def set_designated_times_for_user(user)
      user.designated_work_start_time = Time.current.change(hour: 9, min: 0, sec: 0)
      user.designated_work_end_time = Time.current.change(hour: 18, min: 0, sec: 0)
    end
end