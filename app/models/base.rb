class Base < ApplicationRecord

  # 必要なバリデーションを追加
  validates :base_number, presence: true, uniqueness: true
  validates :base_name, presence: true, uniqueness: true
end
