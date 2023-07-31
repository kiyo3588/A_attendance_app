# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "0001",
             uid: "ab0001",
             admin: true)

# 上長Aユーザーの作成
User.create!(name: "上長A",
             email: "sample-A@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "1111",
             uid: "1111",
             superior: true)
             
# 上長Bユーザーの作成
User.create!(name: "上長B",
             email: "sample-B@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "2222",
             uid: "2222",
             superior: true)

5.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  employee_number = n + 100
  uid = Faker::Alphanumeric.alphanumeric(number: 2, min_alpha: 2) + Faker::Number.number(digits: 4).to_s # 2文字のランダムな英字と4桁のランダムな数字を生成
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_number: employee_number,
               uid: uid)
end