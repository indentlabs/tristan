module Character
  class LocationField < Field
    field_key :location
  
    def self.value_for(template)
      {
        self.key => Faker::Address.country
      }
    end
  end
end