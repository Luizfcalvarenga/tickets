class State < ApplicationRecord
    has_many :cities
    has_many :events
    has_many :partners
end
