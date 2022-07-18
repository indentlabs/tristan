module Character
  class SuperpowerField < Field
    field_key :superpower
  
    def self.value_for(template)
      {
        self.key => Faker::Superhero.power
      }
    end
  end
end
