module Character
  class NameField < Field
    field_key :name
  
    depends_on :gender
  
    def self.value_for(template)
      name = []

      # First name
      case template.fetch(:gender)
      when 'Male'
        name << Faker::Name.male_first_name
      when 'Female'
        name << Faker::Name.female_first_name
      else
        name << Faker::Name.first_name
      end

      # Middle name(s)
      if rand(100) < 95
        name << Faker::Name.middle_name
      end
      while rand(100) < 10
        name << Faker::Name.middle_name
      end

      # Last name
      name << Faker::Name.last_name

      # Suffix
      if (rand(100) < 5)
        name << Faker::Name.suffix
      end

      {
        self.key => name.join(' ')
      }
    end
  end
end