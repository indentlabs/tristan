module Character
  class EducationField < Field
    field_key :education

    depends_on :age
  
    def self.value_for(template)
      degree = Faker::Demographic.educational_attainment

      case degree.split(' ').last.downcase
      when 'degree'
        degree += " in #{Faker::Educator.subject} from #{Faker::Educator.university}"
      end

      {
        self.key => degree
      }
    end
  end
end