module Character
  class HobbiesField < Field
    field_key :job
  
    def self.value_for(template)
      hobbies = []
      3.times do
        hobbies << Faker::Hobby.activity
      end

      {
        self.key => hobbies.uniq.join(', ')
      }
    end
  end
end