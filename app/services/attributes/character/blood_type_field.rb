module Character
  class BloodTypeField < Field
    field_key :blood_type
  
    def self.value_for(template)
      {
        self.key => Faker::Blood.group
      }
    end
  end
end
