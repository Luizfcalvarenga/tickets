class Access < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :membership, optional: true
  belongs_to :read
  belongs_to :user
  belongs_to :granted_by, class_name: "User"

  CSV_HEADER = %w[ciclista]
  def self.as_csv
    CSV.generate do |csv|
      csv << CSV_HEADER
      all.each do |access|
        csv << [
          # student.surname, 
          # student.given_name, 
          # student.admission_year,
          # student.admission_no,
          access.user.pluck(:email).join(', ')
          # access.hobbies.pluck(:title).join(', ')
        ]
      end
    end
  end
end
