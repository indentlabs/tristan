module Character
  class HeightField < Field
    field_key :height

    depends_on :age
  
    def self.value_for(template)
      case template.fetch(:age, 25)
      when 0..1
        inches = rand(10..30)
      when 1..5
        inches = rand(30..45)
      when 5..10
        inches = rand(40..65)
      when 10..15
        inches = rand(45..70)
      when 15..18
        inches = rand(50..70)
      when 18..50
        inches = rand(50..75)
      when 50..99
        inches = rand(40..70)
      end

      feet   = inches / 12
      inches = inches % 12
      {
        height: "#{feet} ft, #{inches} in"
      }
    end
  end
end