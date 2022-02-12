require Rails.root.join('db/seeds/states_and_cities_populate')
require 'faker'
require 'uri'

puts "Criando lista de estados e cidades..."
StatesAndCitiesPopulate.populate!
puts "-- OK!"

Partner.destroy_all
Read.destroy_all
Pass.destroy_all
Event.destroy_all
User.destroy_all
Membership.destroy_all
DayUse.destroy_all
DayUseSchedule.destroy_all

puts "Criando usuários, partner_users, partner e memberships..."

User.create!(email: "admin@app.com", password: "123456", access: "admin") 

(1..5).each do |user|
  if user == 1
    User.create!(email: "user@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "12345678901", name: Faker::Fantasy::Tolkien.character)
  else
    User.create!(email: "user" + user.to_s + "@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "12345678901", name: Faker::Fantasy::Tolkien.character)
  end
end

(1..5).each do |partner|
  if partner == 1
    User.create!(email: "partner@app.com", password: "123456", access: "partner_admin")
  else
    User.create!(email: "partner" + partner.to_s + "@app.com", password: "123456", access: "partner_admin")
  end
end

state = State.find_by(name: "Minas Gerais")
city = City.find_by(name: "Belo Horizonte")
partner = Partner.create!(name: "Parceiro de demonstração",
                          cnpj: "44.716.365/0001-92",
                          contact_phone_1: "3132235655",
                          cep: "30310700",
                          street_name: "Av. Antônio Abrahão Caram",
                          street_number: "1001",
                          neighborhood: "São José",
                          address_complement: "",
                          city: city,
                          state: state,
                          about: "Morbi enim nunc faucibus a pellentesque sit amet porttitor. Cursus vitae congue mauris rhoncus aenean vel elit scelerisque mauris. Viverra tellus in hac habitasse platea dictumst vestibulum rhoncus. Mi sit ame mauris commodo quis imperdiet massa tincidunt nunc. Arcu odio ut sem nulla pharetra diam sit amet.",
                          kind: "partner",
                          )
                          
partner.logo.attach(io: File.open(Rails.root.join('app/assets/images/redbull_logo.png')),
                  filename: 'redbull_logo.png')
partner.update(main_contact: User.where(access: "partner_admin").first)

User.where(access: "partner_admin").update(partner: Partner.first)

(1..3).each do |assinatura|
  puts "Criando assinatura " + assinatura.to_s + "..."
  Membership.create!(name: assinatura.to_s, price_in_cents: [20, 50, 100].pop, partner: partner, description: "Esta é a assinatura de nível " + assinatura.to_s) 
end

puts "-- OK!"

puts 'Criando eventos...'
2.times do Event.create!(name: Faker::WorldCup.stadium,
                        description: Faker::TvShows::Suits.quote,
                        scheduled_start: Faker::Date.between(from: Date.today, to: rand(5..15).days.from_now),
                        scheduled_end: Faker::Date.between(from: Date.today, to: rand(15..30).days.from_now),
                        partner: Partner.first,
                        state: state,
                        city: city,
                        street_name: "Av. Antônio Abrahão Caram",
                        street_number: "1001",
                        neighborhood: "São José",
                        cep: "30310700",
                        address_complement: "Mais próximo do que longe!",
                        created_by: User.where(access: "partner_admin").sample,
                        partner_id: Partner.first.id
  )
  
  event = Event.last
  url = Faker::LoremFlickr.image(size: "640x480", search_terms: ['bike+race'])
  filename = File.basename(URI.parse(url.to_s).path)
  file = URI.open(url.to_s)
  event.photo.attach(io: file, filename: filename, content_type: 'image/jpg')
end

(1..2).each do |event|
  puts 'Criando batches do evento '+ event.to_s + '...'
  EventBatch.create!(event: Event.find(event),
                    name: ['Primeiro lote', 'Segundo lote'].sample,
                    quantity: [10, 20, 30, 40].sample,
                    pass_type: %w[Arquibancada Pista Camarote VIP].sample,
                    price_in_cents: [20, 50, 75, 100].pop,
                    ends_at: Faker::Date.between(from: Date.today, to: rand(5..15).days.from_now),
  )
end

puts 'Criando day uses...'

2.times do DayUse.create!(name: Faker::Marketing.buzzwords.titleize,
                          description: Faker::TvShows::Suits.quote,
                          partner_id: Partner.first.id,
)
  day_use_img = DayUse.last
  url = Faker::LoremFlickr.image(size: "1024x720", search_terms: ['mountain+bike', 'downhill+bike+race', 'speed+bike+race'])
  filename = File.basename(URI.parse(url.to_s).path)
  file = URI.open(url.to_s)
  day_use_img.photo.attach(io: file, filename: filename, content_type: 'image/jpg')
end

rand(1..8).times do |dayuse|

  puts 'Criando day use schedule '+ (dayuse + 1).to_s + ' do Day Use ' + DayUse.last.name.to_s + '...'
  DayUseSchedule.create!( day_use: DayUse.last,
                          weekday: %w[monday tuesday wednesday thursday friday saturday sunday].sample,
                          start_time: Time.new.beginning_of_day + rand(0..3).hours,
                          end_time: Time.new.middle_of_day + rand(0..6).hours,
                          price_in_cents: [25, 50, 75, 100].sample,
)
end

puts "All done!!!"
