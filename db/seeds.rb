# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Partner.destroy_all
Read.destroy_all
Qrcode.destroy_all
Event.destroy_all
User.destroy_all

User.create!(email: "user@test.com", password: "123456", access: "user") 
User.create!(email: "user2@test.com", password: "123456", access: "user") 
User.create!(email: "user3@test.com", password: "123456", access: "user") 
User.create!(email: "user4@test.com", password: "123456", access: "user") 
User.create!(email: "user5@test.com", password: "123456", access: "user") 
partner_user1 = User.create!(email: "partner@test.com", password: "123456", access: "partner_admin") 
partner_user2 = User.create!(email: "partner2@test.com", password: "123456", access: "partner_admin") 
partner_user3 = User.create!(email: "partner3@test.com", password: "123456", access: "partner_admin") 
partner_user4 = User.create!(email: "partner4@test.com", password: "123456", access: "partner_admin") 
partner = Partner.create!(name: "Parceiro de demonstração",
                          cnpj: "44.716.365/0001-92",
                          phone_number: "(31) 3223-5655",
                          cep: "30310-700",
                          street_name: "Av. Antônio Abrahão Caram",
                          street_number: "1001",
                          neighborhood: "São José",
                          address_complement: "",
                          city: "Belo Horizonte",
                          state: "MG",
                          kind: "partner",
                          )
partner.update(main_contact: partner_user1)
partner_user1.update(partner: partner)
partner_user2.update(partner: partner)
partner_user3.update(partner: partner)
partner_user4.update(partner: partner)

Membership.create!(name: "Assinatura 1", price: 20, partner: partner, description: "Esta é a assinatura de nível 1")
Membership.create!(name: "Assinatura 2", price: 40, partner: partner, description: "Esta é a assinatura de nível 2")
Membership.create!(name: "Assinatura 3", price: 80, partner: partner, description: "Esta é a assinatura de nível 3")
