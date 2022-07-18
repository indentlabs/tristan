module Character
  class GenderField < Field
    field_key :gender

    def self.value_for(template)
      {
        self.key => Faker::Gender.type
      }
    end
  end
end