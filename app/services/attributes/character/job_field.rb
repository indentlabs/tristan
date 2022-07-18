module Character
  class JobField < Field
    field_key :job
  
    def self.value_for(template)
      {
        self.key => Faker::Company.profession.capitalize,
        dream_job:  Faker::Company.profession.capitalize
      }
    end
  end
end