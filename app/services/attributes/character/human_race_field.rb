module Character
  class HumanRaceField < Field
    field_key :race
  
    def self.value_for(template)
      {
        self.key => Faker::Demographic.race
      }
    end
  end
end