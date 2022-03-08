require 'net/http'
require 'json'

class StatesAndCitiesPopulate
  class << self
    def populate!
      return if State.count.positive?

      states.each do |state|
        state_obj = State.find_or_create_by!(
          acronym: state['acronym'],
          name:    state['name']
        )
        puts "Adicionando estado #{state['name']} e seus municípios"
        state_obj.save
        populate_cities state_obj, state['cities']
      end
    end

    def populate_cities(state, cities = [])
      cities.each do |city|
        city_obj = state.cities.find_or_create_by!(
          name: city['name']
        )
        city_obj.save
      end
    end

    def states
      http = Net::HTTP.new('raw.githubusercontent.com', 443)
      http.use_ssl = true
      JSON.parse http.get('/tulioti/br_populate/master/states.json').body
    end
  end
end
