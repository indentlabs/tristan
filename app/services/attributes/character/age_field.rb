module Character
  class AgeField < Field
    field_key :age

    depends_on :job

    def self.value_for(template)
      age = 2 + rand(15) + rand(15) + rand(5)
      if rand(100) < 30
        age += rand(25)
      end

      {
        self.key => age,
        birthday: Faker::Date.birthday(min_age: age, max_age: age + 1).strftime("%B %-d") # %A, %B %-d, %Y
      }
    end
  end
end
