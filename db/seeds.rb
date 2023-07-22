# coding: utf-8

User.create!(name: "管理者",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

# 上長Aユーザーの作成
User.create!(name: "上長A",
             email: "sample-A@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)
             
# 上長Bユーザーの作成
User.create!(name: "上長B",
             email: "sample-B@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

5.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end