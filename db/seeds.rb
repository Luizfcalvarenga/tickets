require Rails.root.join('db/seeds/states_and_cities_populate')
require 'faker'
require 'uri'

# User.create!(email: "galo@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "11598323660", cep: "30310700", phone_number: "31981981981", name: Faker::Name.name)

NUMBER_OF_USERS = 1
NUMBER_OF_EVENTS = 1
NUMBER_OF_DAY_USES = 1

puts "Criando lista de estados e cidades..."
StatesAndCitiesPopulate.populate!
puts "-- OK!"

# Partner.destroy_all
# Read.destroy_all
# Pass.destroy_all
# Event.destroy_all
# User.destroy_all
# Membership.destroy_all
# DayUse.destroy_all
# DayUseSchedule.destroy_all

# puts "Criando usuários e parceiros..."

admin_user = User.create!(email: "admin@app.com", password: "123456", access: "admin", document_type: "CPF", document_number: "11598323660", cep: "30310700", phone_number: "31994717196", name: "Admin Plataforma")

User.create!(email: "user@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "11264067674", name: Faker::Name.name, cep: "30310700", phone_number: "31994717196")
cpf_numbers = ["62160592030", "32543268065", "85710659002"]
(1..NUMBER_OF_USERS).each do |counter|
  user = User.create!(email: "user#{counter}@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "85710659002", name: "Frodo Bolseiro", cep: "30310700", phone_number: "31994717196")

  # url = "https://placebeard.it/640x360"
  # filename = File.basename(URI.parse(url).path)
  # file = URI.open(url.to_s)
  # user.photo.attach(io: file, filename: filename, content_type: 'image/jpg')
  p "Usuário comum #{user.email} criado"
end

# (1..5).each do |partner|
#   if partner == 1
    User.create!(email: "partner@app.com", password: "123456", access: "partner_admin", document_type: "CPF", document_number: "91467688070", name: "Gandalf the Gray", cep: "30310700", phone_number: "31994717196")
  # else
    User.create!(email: "partner1@app.com", password: "123456", access: "partner_admin", document_type: "CPF", document_number: "27067411041", name: "Samwise Gamgee
      ", cep: "30310700", phone_number: "31994717196")
  # end

  user = User.last
  # url = "https://placebeard.it/640x360"
  # filename = File.basename(URI.parse(url).path)
  # file = URI.open(url.to_s)
  # user.photo.attach(io: file, filename: filename, content_type: 'image/jpg')

  p "Usuário parceiro #{user.email} criado"
# end

state = State.find_by(acronym: "MG")
city = City.find_by(name: "Nova Lima")
partner = Partner.create!(name: "Layback Park",
                          cnpj: "44.716.365/0001-92",
                          contact_phone_1: "3132235655",
                          cep: "34006057",
                          street_name: "Rod. Januário Carneiro",
                          street_number: "20",
                          neighborhood: "Vale do Sereno",
                          address_complement: "",
                          city: city,
                          state: state,
                          about: "Um espaço para todos, feito para celebrar o espírito e a cultura do skate. Os Parks, Casas Dipraia, Basement, Brewpub e Surf House, são os ambientes de experimentação da nossa vibe, a materialização de tudo o que acreditamos e da cultura RTMF. Mais que uma pista de skate, é um espaço inclusivo, feito para criar momentos únicos. É um ambiente aberto, que traz tudo o que amamos e onde promovemos nosso estilo de vida: conectando, inspirando e abraçando todos os tipos de pessoas. Quer beber com os amigos? Temos cerveja. Quer andar de skate (ou aprender)? Temos pista. Quer comer? Temos um centro gastronômico. Tattoo? Passeio em família? Shows? Rolê com os amigos? Arte urbana? Estaremos sempre de portas abertas. ",
                          kind: "bike_park",
                          )

partner.logo.attach(io: File.open(Rails.root.join('app/assets/images/laybacklogo.png')),
                  filename: 'laybacklogo.png')
partner.update(main_contact_id: User.where(access: "partner_admin").first.id)

User.partner_admin.update(partner: Partner.first)

p "Parceiro #{partner.name} criado"

# ["Mensalista básico", "Mensalista premium", "Mensalista VIP"].each do |assinatura|
#   puts "Criando assinatura " + assinatura.to_s + "..."
#   membership = Membership.create!(name: assinatura.to_s,
#     price_in_cents: [2000, 5000, 10000].pop,
#     partner: partner,
#     fee_percentage: 0.0,
#     absorb_fee: false,
#     approved_at: Time.current,
#     approved_by: admin_user,
#     description: "Esta é a assinatura de nível " + assinatura.to_s)

#   min_count = (NUMBER_OF_USERS * 0.2).to_i
#   max_count = min_count + 5
#   max_count = NUMBER_OF_USERS if max_count > NUMBER_OF_USERS

#   User.user.sample((min_count..max_count).to_a.sample).each do |user|
#     user_membership = UserMembership.create(user: user, membership: membership)

#     identifier = SecureRandom.uuid

#     pass = Pass.create(
#       identifier: identifier,
#       user_membership: user_membership,
#       name: membership.name,
#       partner_id: membership.partner_id,
#       user: user,
#       qrcode_svg: RQRCode::QRCode.new(identifier).as_svg(
#         color: "000",
#         shape_rendering: "crispEdges",
#         module_size: 5,
#         standalone: true,
#         use_path: true,
#       ),
#     )

#     print "."
#   end

#   p "Mensalidade #{membership.name} criada"
# end

# puts "-- OK!"

puts 'Criando eventos...'
NUMBER_OF_EVENTS.times do |i|
  scheduled_start = Faker::Date.between(from: Date.today, to: rand(0..15).days.from_now)

  scheduled_start = Date.today if i == 0

  event = Event.create!(name: Faker::BossaNova.song,
    description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
    scheduled_start: scheduled_start,
    scheduled_end: scheduled_start + rand(5..9).hours,
    partner: Partner.first,
    state: state,
    city: city,
    street_name: "Av. Antônio Abrahão Caram",
    street_number: "1001",
    neighborhood: "São José",
    cep: "30310700",
    address_complement: "Mais próximo do que longe!",
    created_by: User.where(access: "partner_admin").sample,
    partner_id: Partner.first.id,
    fee_percentage: rand(0..10),
    absorb_fee: rand < 0.5,
    approved_at: Time.current,
    approved_by: admin_user,
  )

  url = Faker::LoremFlickr.image(size: "640x480", search_terms: ['bike+race'])
  filename = File.basename(URI.parse(url.to_s).path)
  file = URI.open(url.to_s)
  event.photo.attach(io: file, filename: filename, content_type: 'image/jpg')

  puts 'Criando batches do evento '+ event.name.to_s + '...'
  ends_at = Faker::Date.between(from: Date.today, to: rand(5..60).days.from_now)
  %w[Arquibancada Pista Camarote VIP].shuffle.first(rand(2..4)).each do |pass_type|
    (1..3).each do |i|
      EventBatch.create!(event: event,
        name: "Lote #{i}",
        quantity: [5, 10, 20, 40].sample,
        pass_type: pass_type,
        price_in_cents: [2000, 5000, 7500, 10000].sample,
        ends_at: ends_at + (20*i).days,
      )
    end
  end

  event.create_default_questions

  min_count = (NUMBER_OF_USERS * 0.6).to_i
  max_count = min_count + 5
  max_count = NUMBER_OF_USERS if max_count > NUMBER_OF_USERS

  User.user.sample((min_count..max_count).to_a.sample).each do |user|
    order = Order.create(user: user)

    entity = event.reload.open_batches.to_a.sample
    start_time = event.scheduled_start
    end_time = event.scheduled_end
    order_item = OrderItem.create(order: order,
      event_batch_id: entity.id,
      price_in_cents: entity.price_in_cents,
      fee_percentage: entity.fee_percentage,
      absorb_fee: entity.absorb_fee,
      total_in_cents: entity.price_in_cents * (1 + entity.partner.fee_percentage / 100),
      start_time: start_time,
      end_time: end_time,
    )

    event.questions.each do |question|
      value = if question.prompt == "Nome completo"
        Faker::Name.name
      elsif question.prompt == "CPF"
        ["03162488001", "48537826057", "96582679040", "33114131050", "10993508081", "36428679019", "17831332014"].sample
      elsif question.prompt == "CEP"
        (0..7).to_a.map { |i| rand(9) }.join
      end

      QuestionAnswer.create(
        order_item: order_item,
        question_id: question.id,
        value: value,
      )
    end

    order.perform_after_payment_confirmation_actions

    print "."
  end

  p "Evento #{event.name} populado"
end

# puts 'Criando Agendamentos...'

# NUMBER_OF_DAY_USES.times do
#   day_use = DayUse.create!(name: Faker::WorldCup.stadium,
#     description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(" "),
#     partner_id: Partner.first.id,
#     fee_percentage: rand(0..10),
#     absorb_fee: rand < 0.5,
#     approved_at: Time.current,
#     approved_by: admin_user,
#   )

#   url = Faker::LoremFlickr.image(size: "1024x720", search_terms: ['mountain+bike'])
#   filename = File.basename(URI.parse(url.to_s).path)
#   file = URI.open(url.to_s)
#   day_use.photo.attach(io: file, filename: filename, content_type: 'image/jpg')

#   day_use.create_default_questions

#   %w[monday tuesday wednesday thursday friday saturday sunday].shuffle.first(rand(4..7)).each do |weekday|
#     day_use_schedule = DayUseSchedule.create!( day_use: day_use,
#       weekday: weekday,
#       name: Faker::Marketing.buzzwords.titleize,
#       description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
#       opens_at: Time.new.beginning_of_day + rand(0..3).hours,
#       closes_at: Time.new.middle_of_day + rand(0..6).hours)

#     DayUseSchedulePassType.create(
#       name: "Individual",
#       price_in_cents: [2500, 5000, 7500, 10000].sample,
#       day_use_schedule: day_use_schedule)
#   end

#   created_day_use_schedules = day_use.day_use_schedules
#   (%w[monday tuesday wednesday thursday friday saturday sunday] - created_day_use_schedules.map(&:weekday)).each do |weekday|
#     day_use_schedule = DayUseSchedule.create!( day_use: day_use,
#       weekday: weekday,
#       name: Faker::Marketing.buzzwords.titleize,
#       description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
#       opens_at: nil,
#       closes_at: nil)

#     DayUseSchedulePassType.create(
#       name: "Individual",
#       price_in_cents: [2500, 5000, 7500, 10000].sample,
#       day_use_schedule: day_use_schedule)
#   end

#   min_count = (NUMBER_OF_USERS * 0.4).to_i
#   max_count = min_count + 5
#   max_count = NUMBER_OF_USERS if max_count > NUMBER_OF_USERS

#   User.user.sample((min_count..max_count).to_a.sample).each do |user|
#     order = Order.create(user: user)

#      (0..7).to_a.sample(rand(4)).each do |num|
#       date = Time.current + num.days
#       day_use_schedule = day_use.schedule_for_date(date)
#       open_slot = day_use_schedule.open_slots_for_date(date).sample

#       next if open_slot.blank?

#       start_time = open_slot[:start_time]
#       entity = day_use_schedule.day_use_schedule_pass_types.to_a.sample

#       end_time = start_time + entity.day_use_schedule.sanitized_slot_duration_in_minutes.minute
#       order_item = OrderItem.create(order: order,
#         day_use_schedule_pass_type_id: entity.id,
#         price_in_cents: entity.price_in_cents,
#         fee_percentage: entity.fee_percentage,
#         absorb_fee: entity.absorb_fee,
#         total_in_cents: entity.price_in_cents * (1 + entity.partner.fee_percentage / 100),
#         start_time: start_time,
#         end_time: end_time,
#       )

#       day_use.questions.each do |question|
#         value = if question.prompt == "Nome completo"
#           Faker::Name.name
#         elsif question.prompt == "CPF"
#           ["03162488001", "48537826057", "96582679040", "33114131050", "10993508081", "36428679019", "17831332014"].sample
#         elsif question.prompt == "CEP"
#           (0..7).to_a.map { |i| rand(9) }.join
#         end

#         QuestionAnswer.create(
#           order_item: order_item,
#           question_id: question.id,
#           value: value,
#         )
#       end
#     end

#     order.perform_after_payment_confirmation_actions
#     print "."
#   end

#   p "DayUse #{day_use.name} populado"
# end

# puts "All done!!!"
