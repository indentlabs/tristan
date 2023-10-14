module Character
  class EthnicityField < Field
    field_key :ethnicity

    def self.value_for(template)
      { self.key => possible_values.sample }
    end

    def self.possible_values
      %w(American\ Indian Alaskan\ Native Asian Black African\ American Native\ Hawaiian Pacific\ Islander White White White African Caribbean Indian Melanesian Aboriginal Chinese Guamanian Japanese Korean Polynesian European Anglo\ Saxon Latino Arabic Vietnamese Micronesian Hispanic Puerto\ Rican Filipino Mexican Cuban Spaniard Italian Russian)
    end
  end
end