class City < ApplicationRecord
    belongs_to :state
    has_many :events
    has_many :partners
end
