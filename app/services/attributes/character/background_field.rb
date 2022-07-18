module Character
  class BackgroundField < Field
    field_key :background
  
    def self.value_for(template)
      {
        self.key => "background TBD"
      }
    end
  end
end
