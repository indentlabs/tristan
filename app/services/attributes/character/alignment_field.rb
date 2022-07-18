module Character
  class AlignmentField < Field
    field_key :alignment
  
    def self.value_for(template)
      alignment = %w(Lawful Neutral Chaotic).sample + ' ' + %w(Good Neutral Evil).sample
      alignment = 'True Neutral' if alignment == 'Neutral Neutral'

      {
        self.key => alignment
      }
    end
  end
end