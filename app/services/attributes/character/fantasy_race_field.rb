module Character
  class FantasyRaceField < Field
    field_key :species
  
    def self.value_for(template)
      species = if rand(100) < 20
        Faker::Fantasy::Tolkien.race
      else
        possible_values.sample
      end

      {
        self.key => species
      }
    end

    def self.possible_values
      %w(Android Angel Animal Arachnoid Alien Bird Dark\ Elf Dwarf Elemental Elf Fairy Fey Genie Gnome Half-Dwarf Half-Elf Half-Orc Halfling Human Insectoid Orc Reptilian Robot Spirit Troll Vampire Werewolf)
    end
  end
end