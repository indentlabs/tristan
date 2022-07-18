module Character
  class ReligionField < Field
    field_key :religion
  
    def self.value_for(template)
      religion = if rand(100) < 90
        possible_values.sample
      else
        transition = possible_values.sample(2)
        "Transitioning from #{transition.first} to #{transition.last}"
      end

      {
        self.key => religion
      }
    end

    def self.possible_values
      %w(Atheist Agnostic Undecided Syntheism Christianity Catholic Protestant Quaker Baptist Lutheranism Methodism Pentecostalism Unitarianism Calvanism Mormonism Paganism Druidism Wicca Scientology Mysticism Islam Hinduism Buddhism Shinto Taoism Vodou Hoodoo Sikhism Judaism Spiritism Shamanism Caodaism Confucianism Jainism Cheondoism Zoroastrianism Rastafari Pastafarianism Jediism Luciferianism Occultism Satanism Chrislam Witch)
    end
  end
end