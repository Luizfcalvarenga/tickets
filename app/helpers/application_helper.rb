require Rails.root.join('db/seeds/states_and_cities_populate')
require 'faker'
require 'open-uri'

module ApplicationHelper
  def display_price(price_in_cents)
    number_to_currency(price_in_cents/100, unit: "R$", separator: ",", delimiter: ".")
  end

  def cpf_mask(cpf)
    cpf.insert(3, ".").insert(7, ".").insert(11, "-")
  end

  def month_number_to_name_abr(month_number)
    {
      "1" => "Jan",
      "2" => "Fev",
      "3" => "Mar",
      "4" => "Abr",
      "5" => "Mai",
      "6" => "Jun",
      "7" => "Jul",
      "8" => "Ago",
      "9" => "Set",
      "10" => "Out",
      "11" => "Nov",
      "12"=> "Dez",
    }[month_number.to_s]
  end

  def weekday_number_to_name_abr(weekday_number)
    {
      "0" => "Dom",
      "1" => "Seg",
      "2" => "Ter",
      "3" => "Qua",
      "4" => "Qui",
      "5" => "Sex",
      "6" => "Sab",
    }[weekday_number.to_s]
  end

  def seed_db_10_events
    puts "Criando lista de estados e cidades..."
    StatesAndCitiesPopulate.populate!
    puts "-- OK!"

    Pass.destroy_all
    Read.destroy_all
    DayUseSchedulePassType.destroy_all
    DayUseSchedule.destroy_all
    EventBatchQuestion.destroy_all
    Question.destroy_all
    DayUse.destroy_all
    Event.destroy_all
    Membership.destroy_all
    Partner.destroy_all
    Order.destroy_all
    User.destroy_all

    puts "Criando usuários e parceiros..."

    User.create!(email: "admin@app.com", password: "123456", access: "admin") 

    (1..5).each do |user|
      if user == 1
        User.create!(email: "user@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "12345678901", name: Faker::Fantasy::Tolkien.character)
      else
        User.create!(email: "user" + user.to_s + "@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "12345678901", name: Faker::Fantasy::Tolkien.character)
      end

      user = User.last
      url = "https://placebeard.it/640x360"
      filename = File.basename(URI.parse(url).path)
      file = URI.open(url.to_s)
      user.photo.attach(io: file, filename: filename, content_type: 'image/jpg')

    end

    (1..5).each do |partner|
      if partner == 1
        User.create!(email: "partner@app.com", password: "123456", access: "partner_admin")
      else
        User.create!(email: "partner" + partner.to_s + "@app.com", password: "123456", access: "partner_admin")
      end
      
      user = User.last
      url = "https://placebeard.it/640x360"
      filename = File.basename(URI.parse(url).path)
      file = URI.open(url.to_s)
      user.photo.attach(io: file, filename: filename, content_type: 'image/jpg')
    end

    state = State.first
    city = City.first
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
                              about: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
                              kind: "partner",
                              )
                              
    partner.logo.attach(io: File.open(Rails.root.join('app/assets/images/redbull_logo.png')),
                      filename: 'redbull_logo.png')
    partner.update(main_contact: User.where(access: "partner_admin").first)

    User.where(access: "partner_admin").update(partner: Partner.first)

    ["Mensalista básico", "Mensalista premium", "Mensalista VIP"].each do |assinatura|
      puts "Criando assinatura " + assinatura.to_s + "..."
      Membership.create!(name: assinatura.to_s, price_in_cents: [2000, 5000, 10000].pop, partner: partner, description: "Esta é a assinatura de nível " + assinatura.to_s) 
    end

    puts "-- OK!"

    puts 'Criando eventos...'
    10.times do 
      scheduled_start = Faker::Date.between(from: Date.today, to: rand(5..15).days.from_now)
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
        partner_id: Partner.first.id
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
            quantity: [10, 20, 30, 40].sample,
            pass_type: pass_type,
            price_in_cents: [2000, 5000, 7500, 10000].sample,
            ends_at: ends_at + (20*i).days,
          )
        end
      end

      event.create_default_questions
    end

    puts 'Criando day uses...'

    1.times do
      day_use = DayUse.create!(name: Faker::WorldCup.stadium,
        description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(" "),
        partner_id: Partner.first.id,
      )

      url = Faker::LoremFlickr.image(size: "1024x720", search_terms: ['mountain+bike'])
      filename = File.basename(URI.parse(url.to_s).path)
      file = URI.open(url.to_s)
      day_use.photo.attach(io: file, filename: filename, content_type: 'image/jpg')

      day_use.create_default_questions

      %w[monday tuesday wednesday thursday friday saturday sunday].shuffle.first(rand(4..7)).each do |weekday|
        day_use_schedule = DayUseSchedule.create!( day_use: day_use,
          weekday: weekday,
          name: Faker::Marketing.buzzwords.titleize,
          description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
          opens_at: Time.new.beginning_of_day + rand(0..3).hours,
          closes_at: Time.new.middle_of_day + rand(0..6).hours)

        DayUseSchedulePassType.create(
          name: "Individual",
          price_in_cents: [2500, 5000, 7500, 10000].sample,
          day_use_schedule: day_use_schedule)
      end

      created_day_use_schedules = day_use.day_use_schedules
      (%w[monday tuesday wednesday thursday friday saturday sunday] - created_day_use_schedules.map(&:weekday)).each do |weekday|
        day_use_schedule = DayUseSchedule.create!( day_use: day_use,
          weekday: weekday,
          name: Faker::Marketing.buzzwords.titleize,
          description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
          opens_at: nil,
          closes_at: nil)
        
        DayUseSchedulePassType.create(
          name: "Individual",
          price_in_cents: [2500, 5000, 7500, 10000].sample,
          day_use_schedule: day_use_schedule)
      end
    end

    puts "All done!!!"

  end

  def seed_db_1_event
    puts "Criando lista de estados e cidades..."
    StatesAndCitiesPopulate.populate!
    puts "-- OK!"

    Pass.destroy_all
    Read.destroy_all
    DayUseSchedulePassType.destroy_all
    DayUseSchedule.destroy_all
    EventBatchQuestion.destroy_all
    Question.destroy_all
    DayUse.destroy_all
    Event.destroy_all
    Membership.destroy_all
    Partner.destroy_all
    Order.destroy_all
    User.destroy_all

    puts "Criando usuários e parceiros..."

    User.create!(email: "admin@app.com", password: "123456", access: "admin") 

    (1..5).each do |user|
      if user == 1
        User.create!(email: "user@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "12345678901", name: Faker::Fantasy::Tolkien.character)
      else
        User.create!(email: "user" + user.to_s + "@app.com", password: "123456", access: "user", document_type: "CPF", document_number: "12345678901", name: Faker::Fantasy::Tolkien.character)
      end

      user = User.last
      url = "https://placebeard.it/640x360"
      filename = File.basename(URI.parse(url).path)
      file = URI.open(url.to_s)
      user.photo.attach(io: file, filename: filename, content_type: 'image/jpg')

    end

    (1..5).each do |partner|
      if partner == 1
        User.create!(email: "partner@app.com", password: "123456", access: "partner_admin")
      else
        User.create!(email: "partner" + partner.to_s + "@app.com", password: "123456", access: "partner_admin")
      end
      
      user = User.last
      url = "https://placebeard.it/640x360"
      filename = File.basename(URI.parse(url).path)
      file = URI.open(url.to_s)
      user.photo.attach(io: file, filename: filename, content_type: 'image/jpg')
    end

    state = State.first
    city = City.first
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
                              about: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
                              kind: "partner",
                              )
                              
    partner.logo.attach(io: File.open(Rails.root.join('app/assets/images/redbull_logo.png')),
                      filename: 'redbull_logo.png')
    partner.update(main_contact: User.where(access: "partner_admin").first)

    User.where(access: "partner_admin").update(partner: Partner.first)

    ["Mensalista básico", "Mensalista premium", "Mensalista VIP"].each do |assinatura|
      puts "Criando assinatura " + assinatura.to_s + "..."
      Membership.create!(name: assinatura.to_s, price_in_cents: [2000, 5000, 10000].pop, partner: partner, description: "Esta é a assinatura de nível " + assinatura.to_s) 
    end

    puts "-- OK!"

    puts 'Criando eventos...'
    1.times do 
      scheduled_start = Faker::Date.between(from: Date.today, to: rand(5..15).days.from_now)
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
        partner_id: Partner.first.id
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
            quantity: [10, 20, 30, 40].sample,
            pass_type: pass_type,
            price_in_cents: [2000, 5000, 7500, 10000].sample,
            ends_at: ends_at + (20*i).days,
          )
        end
      end

      event.create_default_questions
    end

    puts 'Criando day uses...'

    2.times do
      day_use = DayUse.create!(name: Faker::WorldCup.stadium,
        description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(" "),
        partner_id: Partner.first.id,
      )

      url = Faker::LoremFlickr.image(size: "1024x720", search_terms: ['mountain+bike'])
      filename = File.basename(URI.parse(url.to_s).path)
      file = URI.open(url.to_s)
      day_use.photo.attach(io: file, filename: filename, content_type: 'image/jpg')

      day_use.create_default_questions

      %w[monday tuesday wednesday thursday friday saturday sunday].shuffle.first(rand(4..7)).each do |weekday|
        day_use_schedule = DayUseSchedule.create!( day_use: day_use,
          weekday: weekday,
          name: Faker::Marketing.buzzwords.titleize,
          description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
          opens_at: Time.new.beginning_of_day + rand(0..3).hours,
          closes_at: Time.new.middle_of_day + rand(0..6).hours)

        DayUseSchedulePassType.create(
          name: "Individual",
          price_in_cents: [2500, 5000, 7500, 10000].sample,
          day_use_schedule: day_use_schedule)
      end

      created_day_use_schedules = day_use.day_use_schedules
      (%w[monday tuesday wednesday thursday friday saturday sunday] - created_day_use_schedules.map(&:weekday)).each do |weekday|
        day_use_schedule = DayUseSchedule.create!( day_use: day_use,
          weekday: weekday,
          name: Faker::Marketing.buzzwords.titleize,
          description: (1..20).map { |i| Faker::TvShows::Suits.quote}.join(". "),
          opens_at: nil,
          closes_at: nil)
        
        DayUseSchedulePassType.create(
          name: "Individual",
          price_in_cents: [2500, 5000, 7500, 10000].sample,
          day_use_schedule: day_use_schedule)
      end
    end

    puts "All done!!!"

  end
end
