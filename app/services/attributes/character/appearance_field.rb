module Character
  class AppearanceField < Field
    field_key :appearance

    depends_on :gender, :ethnicity

    def self.value_for(template)
      optional_values = {}

      if rand(100) < 90
        eye_color = eye_colors.sample
      else
        eye_color = "one #{eye_colors.sample.downcase}, one #{eye_colors.sample.downcase}"
      end

      # Facial hair
      if rand(100) < 50 && template.fetch(:gender, nil) == 'Male'
        optional_values[:facial_hair] = facial_hairs.sample
      end

      # Hair color/style
      hair_color = hair_colors.sample
      unless %w(Bald).include? hair_color
        hair_style = hair_styles.sample
      end
      hair_description = "#{hair_color} #{hair_style.downcase}"

      # Skin tone
      unless template.include?('ethnicity')
        optional_values[:skin_tone] = skin_tones.sample
      end

      {
        body_type:  body_types.sample,
        eye_color:  eye_color,
        hair:       hair_description,
      }.merge(optional_values)
    end

    def self.body_types
      %w(Delicate Flat Fragile Lean Lightly\ muscled Small-shouldered Thin Athletic Hourglass Bodybuilder Rectangular Muscular Thick-skinned Big-boned Round\ physique Pear-shaped)
    end

    def self.eye_colors
      %w(Amber Black Arctic\ blue Baby\ blue China\ blue Cornflower\ blue Crystal\ blue Denim\ blue Electric\ blue Indigo Sapphire\ blue Sky\ blue Champagne\ brown Chestnut\ brown Chocolate\ brown Golden\ brown Honey\ brown Topaz Charcoal\ grey Cloudy\ grey Steel\ grey Chartreuse Emerald\ green Forest\ green Grass\ green Jade\ green Leaf\ green Sea\ green Seafoam Hazel Amethyst Hyacinth Ultramarine\ blue Light\ violet Dark\ violet)
    end

    def self.facial_hairs
      %w(Long\ beard Short\ beard Chin\ curtain Chinstrap Fu\ Manchu Goatee Handlebar\ mustache Horseshoe\ mustache Mustache Mutton\ chops Neckbeard Pencil\ mustache Shenandoah Sideburns Soul\ patch Light\ stubble Dark\ stubble Toothbrush\ mustache Van\ Dyke\ beard Patchy\ beard Patchy\ mustache Braided\ beard Braided\ mustache Twirled\ mustache)
    end

    def self.hair_colors
      %w(Blonde Black Brown Red Bald White Grey Balding Greying Bleached Blue Green Purple Orange Auburn Strawberry Chestnut Dirty\ Blonde Rainbow Jet\ black Raven\ black)
    end

    def self.hair_styles
      %w(Afro Bob\ cut Bowl\ cut Bouffant Braided Bun Butch Buzz\ cut Cignon Chonmage Combover Cornrows Crew\ cut Dreadlocks Emo Fauxhawk Feathered Flattop Fringe Liberty\ spikes Straight\ long Curly\ long Wavy\ long Thin\ long Mohawk Mop-top Parted Pigtails Pixie\ cut Pompadour Ponytail Rat-tail Rocker Slicked\ back Spiked Curly\ short Wavy\ short Thin\ short Straight\ short)
    end

    def self.skin_tones
      %w(Albino Light Pale Fair White Grey Medium Olive Moderate\ brown Brown Dark\ brown Chocolate Black)
    end
  end
end