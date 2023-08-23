class Attendance < ApplicationRecord
  belongs_to :user

  # approverに関するアソシエーション
  belongs_to :approver, class_name: "User", optional: true, foreign_key: "overtime_approver_id"

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  validates :overtime_task, length: { maximum: 100 }

  enum attendance_status: {
    attendance_no_request: 0, 
    attendance_pending: 1, 
    attendance_approved: 2, 
    attendance_declined: 3 
  }

enum overtime_status: {
  overtime_no_request: 0, 
  overtime_pending: 1, 
  overtime_approved: 2, 
  overtime_declined: 3 
}

  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  validate :overtime_end_at_validity

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end

  def overtime_end_at_validity
    # 例: 出勤時間よりも前の残業終了時間は無効
    if started_at.present? && overtime_end_at.present? && started_at > overtime_end_at
      errors.add(:overtime_end_at, "は出勤時間よりも後である必要があります")
    end
  end
end
