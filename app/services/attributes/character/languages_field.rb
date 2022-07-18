module Character
  class LanguagesField < Field
    field_key :languages
  
    def self.value_for(template)
      languages = [Faker::Nation.language]
      while rand(100) < 10
        languages << Faker::Nation.language
      end

      {
        self.key => languages.uniq.join(', ')
      }
    end
  end
end