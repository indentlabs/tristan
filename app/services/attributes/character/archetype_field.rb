module Character
  class ArchetypeField < Field
    field_key :archetype
  
    def self.value_for(template)
      {
        self.key => possible_values.sample
      }
    end

    def self.possible_values
      %w(Anthropomorphic\ Personification Anti-Hero Archmage Barefoot\ Sage Background\ Character Big\ Fun Blind\ Seer Blue-Collar\ Warlock Bruiser\ with\ a\ Soft\ Center The\ Champion The\ Chosen\ One The\ Chooser\ of\ The\ One Classic\ Villain The\ Cynic The\ Dragonslayer The\ Drunken\ Sailor Dumb\ Muscle Eccentric\ Mentor Enigmatic\ Empowering\ Entity Evil\ Overlord The\ Fair\ Folk Father\ Neptune Ferryman The\ Fool Fool\ for\ Love Gary\ Sue Gentle\ Giant The\ Good\ King Granny\ Classic The\ Grotesque Herald Heroic\ Archetype Heroic\ Wannabe The\ High\ Queen Higher\ Self The\ Hunter Ideal\ Hero The\ Idealist Ineffectual\ Loner The\ Kirk The\ Klutz Knight\ in\ Shining\ Armor Lady\ and\ Knight Loser\ Archetype Lovable\ Rogue Magical\ Barefooter Mary\ Sue The\ McCoy Mentor Messianic Mixed Mock\ Millionaire Modern\ Major\ General My\ Girl\ Back\ Home Obstructive\ Bureaucrat Oedipus\ Complex Old\ Soldier The\ Paladin The\ Patriarch Person\ of\ Mass\ Destruction The\ Pollyanna Powers\ That\ Be Prince\ Charming Princess\ Classic Protagonist Rebel\ Leader Rebellious\ Spirit Reluctant\ Monster Satanic\ Archetype Seeker\ Archetype Shadow\ Archetype Shapeshifter Side\ Character The\ Spock Star-Crossed\ Lovers The\ Storyteller Threshold\ Guardians Turn\ Coat The\ Trickster Visitor Wicked\ Stepmother Wicked\ Witch Wizard\ Classic Wolf\ Man Witch)
    end
  end
end