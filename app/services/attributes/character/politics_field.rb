module Character
  class PoliticsField < Field
    field_key :politics

    depends_on :age
  
    def self.value_for(template)
      politics = affiliations.sample
  
      if rand(100) < 5
        politics = 'Extremist ' + politics
      end

      if template.fetch(:age, 25) < 10
        politics = "Being raised #{politics}"
      end

      {
        self.key => affiliation
      }
    end

    def self.affiliations
      %w(Democrat Republican Liberal Conservative Libertarian Progressive Centrist Independent Socialist Communist Imperialist Nationalist Environmentalism Constitutionalist Paleoconservatism Reformist Radical\ Centrism Marxism–Leninism Anarchist Temperance Piracy Transhumanism Populism Nativism Distributism Neo-fascism Secularism Fiscal\ Conservatism Anarcho-socialism)
    end
  end
end