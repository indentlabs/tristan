require 'discordrb'
require 'faker'
require 'pry'
require 'redis'

require 'random_word'
require 'bazaar'

# @redis = Redis.new(host: "localhost")
@redis = Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })

# Permissions auth:
# https://discord.com/api/oauth2/authorize?client_id=993994793225031810&permissions=277025442880&scope=applications.commands%20bot

def character_background(template)
  name = template.fetch(:name, 'this character')

  background_templates = [
    "<name> grew up in <country> with <possessive-adjective> <direct-family-member>.",
    "<name> moved to <country> with <possessive-adjective> <direct-family-member> when <subject-pronoun> turned <smaller-age>.",
    "<name> grew up as the only <demonym> in <country> and often felt <emotion-noun>."
  ]

  additional_fact_templates = [
    # "<fact:hero>",
    # "<fact:superhero>",
    # "<fact:invention>",
    # "<fact:exaggeration>",
    "<fact:emotion>",
    "<name> tried to pick up <hobby>, but it was too hard.",
    "<name> is expected to go into the family job in <industry>.",
    "<name> has a very close relationship with <possessive-adjective> <any-family-member>.",
    "<possessive-adjective> friends describe <object-pronoun> as <random-adjective> and <random-adjective>."
  ]

  replacements = {
    # Maybe denote field-lookups differently so we can abstract them out? (@name @profession etc)
    '<name>'                   => -> template { template.fetch(:name, 'this character') },
    '<profession>'             => -> template { template.fetch(:profession, 'unemployed') },
    '<country>'                => -> template { template.fetch(:country, "<possessive-adjective> country") },

    # Metadata/context (probably use same as above: @object-pronoun, etc)
    '<object-pronoun>'         => -> template { object_pronoun(template) },
    '<subject-pronoun>'        => -> template { subject_pronoun(template) },
    '<possessive-adjective>'   => -> template { possessive_adjective(template) },
    '<smaller-age>'            => -> template { 1 + rand(template.fetch(:age, 50) - 1) },

    # Related content <country> <appliance>
    '<appliance>'              => -> template { Faker::Appliance.equipment },
    '<any-family-member>'      => -> template { Faker::Relationship.familial },
    '<direct-family-member>'   => -> template { Faker::Relationship.familial(connection: 'direct').downcase },
    '<extended-family-member>' => -> template { Faker::Relationship.familial(connection: 'extended').downcase },
    '<spousal-family-member>'  => -> template { Faker::Relationship.spouse },
    '<parental-family-member>' => -> template { Faker::Relationship.parent },
    '<in-law-family-member>'   => -> template { Faker::Relationship.in_law },
    '<sibling-family-member>'  => -> template { Faker::Relationship.sibling },
    '<material>'               => -> template { Faker::Commerce.material }, # or Faker::Construction.material
    '<invention>'              => -> template { Faker::Commerce.product_name },
    '<company>'                => -> template { Faker::Company.name },
    '<industry>'               => -> template { Faker::Company.industry }, # also Faker::IndustrySegments.industry
    '<compass-direction>'      => -> template { Faker::Compass.direction },
    '<hero>'                   => -> template { Faker::Ancient.hero },
    '<superhero>'              => -> template { Faker::DcComics.hero }, # men only unless you use superheroine
    '<superheroine>'           => -> template { Faker::DcComics.heroine },
    '<villain>'                => -> template { Faker::DcComics.villain },
    '<demonym>'                => -> template { Faker::Demographic.demonym }, # American, Chinese, Pole, etc
    '<emotion-noun>'           => -> template { Faker::Emotion.noun },
    '<emotion-adjective>'      => -> template { Faker::Emotion.adjective },
    '<hobby>'                  => -> template { Faker::Hobby.activity },
    '<furniture>'              => -> template { Faker::House.furniture },
    '<room>'                   => -> template { Faker::House.room },
    '<capital-city>'           => -> template { Faker::Nation.capital_city },
    '<language>'               => -> template { Faker::Nation.language },
    '<nationality>'            => -> template { Faker::Nation.nationality },
    '<planet>'                 => -> template { Faker::Space.planet },
    '<moon>'                   => -> template { Faker::Space.moon },
    '<galaxy>'                 => -> template { Faker::Space.galaxy },
    '<star>'                   => -> template { Faker::Space.star },
    '<meteorite>'              => -> template { Faker::Space.meteorite },
    '<sport>'                  => -> template { Faker::Team.sport },
    '<car-manufacturer>'       => -> template { Faker::Vehicle.manufacture },
    '<car-make>'               => -> template { Faker::Vehicle.make },
    '<car-model>'              => -> template { template.key?('car-make') ? Faker::Vehicle.model(make_of_model: template['car-make']) : Fake::Vehicle.model },
    '<car-color>'              => -> template { Faker::Vehicle.color },
    '<army-rank>'              => -> template { Faker::Military.army_rank },
    '<marine-rank>'            => -> template { Faker::Military.marines_rank },
    '<navy-rank>'              => -> template { Faker::Military.navy_rank },
    '<air-force-rank>'         => -> template { Faker::Military.air_force_rank },
    '<space-force-rank>'       => -> template { Faker::Military.space_force_rank },
    '<coast-guard-rank>'       => -> template { Faker::Military.coast_guard_rank },
    '<random-adjective>'       => -> template { RandomWord.adjs.next },
    '<random-item>'            => -> template { Bazaar.item },

    # Dis/ambiguations
    # '<random-family-member>'   => -> template { ["<direct-family-member>", "<extended-family-member>"].sample } # replaced by native faker func

    # Facts (#hero #exaggeration #invention)
    '<fact:hero>'              => -> template { "<possessive-adjective> favorite historical hero is <hero>." },
    '<fact:superhero>'         => -> template { "<possessive-adjective> favorite superhero is <superhero>." },
    '<fact:exaggeration>'      => -> template { Faker::ChuckNorris.fact.gsub('Chuck Norris', '<name>') },
    '<fact:invention>'         => -> template { "<name> invented the #{Faker::Company.buzzword} <invention> (for only $#{Faker::Commerce.price(range: 0..10.0, as_string: true)} at #{Faker::Commerce.vendor}!)."},
    '<fact:emotion>'           => -> template { "<name> often feels <emotion-adjective> and <emotion-adjective>."}
  }

  background = background_templates.sample + ' ' + additional_fact_templates.sample(2).join(' ')
  max_cycles = 50
  while true
    puts "Template: #{background}"
    changes = background.gsub!(/<([a-zA-Z\-:]+)>/) do |token|
      if replacements.key?(token)
        replacements[token].call(template)
      else
        token.upcase
      end
    end

    max_cycles -= 1
    break if changes.nil? || max_cycles <= 0
  end

  background
end

def object_pronoun(template)
  if template.key?(:pronouns)
    # he/him
    return template.fetch(:pronouns, '').split('/').last
  end

  case template.fetch(:gender, nil)
  when 'Male'
    'his'
  when 'Female'
    'her'
  else
    'them'
  end
end

def subject_pronoun(template)
  if template.key?(:pronouns)
    # he/him
    return template.fetch(:pronouns, '').split('/').first
  end

  case template.fetch(:gender, nil)
  when 'Male'
    'he'
  when 'Female'
    'she'
  else
    'they'
  end
end

def possessive_adjective(template)
  case template.fetch(:gender, nil)
  when 'Male'
    'his'
  when 'Female'
    'her'
  else
    'their'
  end
end

def generate_character(event:, template:)
  puts "Generating a character [#{template.join(',')}] for #{event.interaction.user.username}"
  character_template = {}
  character_template[:name] = Faker::Name.name if template.include?('name')

  if template.include?('archetype')
    character_template[:archetype] = %w(Anthropomorphic\ Personification Anti-Hero Archmage Barefoot\ Sage Background\ Character Big\ Fun Blind\ Seer Blue-Collar\ Warlock Bruiser\ with\ a\ Soft\ Center The\ Champion The\ Chosen\ One The\ Chooser\ of\ The\ One Classic\ Villain The\ Cynic The\ Dragonslayer The\ Drunken\ Sailor Dumb\ Muscle Eccentric\ Mentor Enigmatic\ Empowering\ Entity Evil\ Overlord The\ Fair\ Folk Father\ Neptune Ferryman The\ Fool Fool\ for\ Love Gary\ Sue Gentle\ Giant The\ Good\ King Granny\ Classic The\ Grotesque Herald Heroic\ Archetype Heroic\ Wannabe The\ High\ Queen Higher\ Self The\ Hunter Ideal\ Hero The\ Idealist Ineffectual\ Loner The\ Kirk The\ Klutz Knight\ in\ Shining\ Armor Lady\ and\ Knight Loser\ Archetype Lovable\ Rogue Magical\ Barefooter Mary\ Sue The\ McCoy Mentor Messianic Mixed Mock\ Millionaire Modern\ Major\ General My\ Girl\ Back\ Home Obstructive\ Bureaucrat Oedipus\ Complex Old\ Soldier The\ Paladin The\ Patriarch Person\ of\ Mass\ Destruction The\ Pollyanna Powers\ That\ Be Prince\ Charming Princess\ Classic Protagonist Rebel\ Leader Rebellious\ Spirit Reluctant\ Monster Satanic\ Archetype Seeker\ Archetype Shadow\ Archetype Shapeshifter Side\ Character The\ Spock Star-Crossed\ Lovers The\ Storyteller Threshold\ Guardians Turn\ Coat The\ Trickster Visitor Wicked\ Stepmother Wicked\ Witch Wizard\ Classic Wolf\ Man Witch).sample
  end

  if template.include?('gender')
    character_template[:gender] = Faker::Gender.type
  end

  if template.include?('name')
    name = []

    # First name
    case character_template.fetch(:gender, nil)
    when 'Male'
      name << Faker::Name.male_first_name
    when 'Female'
      name << Faker::Name.female_first_name
    else
      name << Faker::Name.first_name
    end

    # Middle name(s)
    if rand(100) < 95
      name << Faker::Name.middle_name
    end
    while rand(100) < 10
      name << Faker::Name.middle_name
    end

    # Last name
    name << Faker::Name.last_name

    # Suffix
    if (rand(100) < 5)
      name << Faker::Name.suffix
    end

    character_template[:name] = name.join(' ')
  end

  if template.include?('age')
    age = 2 + rand(15) + rand(15) + rand(5)
    if rand(100) < 30
      age += rand(25)
    end

    character_template[:age] = age
    character_template[:birthday] = Faker::Date.birthday(min_age: age, max_age: age + 1).strftime("%B %-d") # %A, %B %-d, %Y
  end

  if template.include?('ethnicity')
    # character_template[:ethnicity] = %w(African Asian White Hispanic Latino American Inuit Native Bouyei Han\ Chinese Gaoshan\ Han Akan Mixed Native\ American Indigenous Micronesian Islander Polynesian Person\ of\ color Russian Uyghur Romani Indian Pakistani Chinese Arab).sample
    character_template[:ethnicity] = %w(American\ Indian Alaskan\ Native Asian Black African\ American Native\ Hawaiian Pacific\ Islander White White White African Caribbean Indian Melanesian Aboriginal Chinese Guamanian Japanese Korean Polynesian European Anglo\ Saxon Latino Arabic Vietnamese Micronesian Hispanic Puerto\ Rican Filipino Mexican Cuban Spaniard Italian Russian).sample
  end

  if template.include?('appearance')
    # These are ripped from Notebook.ai. Maybe we should just import the autocomplete/en.yml file they're from.
    character_template[:body_type] = %w(Delicate Flat Fragile Lean Lightly\ muscled Small-shouldered Thin Athletic Hourglass Bodybuilder Rectangular Muscular Thick-skinned Big-boned Round\ physique Pear-shaped).sample

    # Eye color
    eye_colors = %w(Amber Black Arctic\ blue Baby\ blue China\ blue Cornflower\ blue Crystal\ blue Denim\ blue Electric\ blue Indigo Sapphire\ blue Sky\ blue Champagne\ brown Chestnut\ brown Chocolate\ brown Golden\ brown Honey\ brown Topaz Charcoal\ grey Cloudy\ grey Steel\ grey Chartreuse Emerald\ green Forest\ green Grass\ green Jade\ green Leaf\ green Sea\ green Seafoam Hazel Amethyst Hyacinth Ultramarine\ blue Light\ violet Dark\ violet)
    if rand(100) < 90
      character_template[:eye_color] = eye_colors.sample
    else
      character_template[:eye_color] = "one #{eye_colors.sample.downcase}, one #{eye_colors.sample.downcase}"
    end

    # Facial hair
    if rand(100) < 50 && character_template.fetch(:gender, nil) == 'Male'
      character_template[:facial_hair] = %w(Long\ beard Short\ beard Chin\ curtain Chinstrap Fu\ Manchu Goatee Handlebar\ mustache Horseshoe\ mustache Mustache Mutton\ chops Neckbeard Pencil\ mustache Shenandoah Sideburns Soul\ patch Light\ stubble Dark\ stubble Toothbrush\ mustache Van\ Dyke\ beard Patchy\ beard Patchy\ mustache Braided\ beard Braided\ mustache Twirled\ mustache).sample
    end

    # Hair color/style
    hair_color = %w(Blonde Black Brown Red Bald White Grey Balding Greying Bleached Blue Green Purple Orange Auburn Strawberry Chestnut Dirty\ Blonde Rainbow Jet\ black Raven\ black).sample
    hair_style = ''
    unless %w(Bald).include? hair_color
      hair_style = %w(Afro Bob\ cut Bowl\ cut Bouffant Braided Bun Butch Buzz\ cut Cignon Chonmage Combover Cornrows Crew\ cut Dreadlocks Emo Fauxhawk Feathered Flattop Fringe Liberty\ spikes Straight\ long Curly\ long Wavy\ long Thin\ long Mohawk Mop-top Parted Pigtails Pixie\ cut Pompadour Ponytail Rat-tail Rocker Slicked\ back Spiked Curly\ short Wavy\ short Thin\ short Straight\ short).sample
    end
    character_template[:hair] = hair_color + ' ' + hair_style.downcase

    # Skin tone
    unless template.include?('ethnicity')
      character_template[:skin_tone] = %w(Albino Light Pale Fair White Grey Medium Olive Moderate\ brown Brown Dark\ brown Chocolate Black).sample
    end
  end

  if template.include?('alignment')
    alignment = %w(Lawful Neutral Chaotic).sample + ' ' + %w(Good Neutral Evil).sample
    alignment = 'True Neutral' if alignment == 'Neutral Neutral'
    character_template[:alignment] = alignment
  end

  if template.include?('race')
    character_template[:race] = Faker::Demographic.race
  end

  if template.include?('fantasy-race')
    if rand(100) < 30
      character_template[:species] = Faker::Fantasy::Tolkien.race
    else
      character_template[:species] = %w(Android Angel Animal Arachnoid Alien Bird Dark\ Elf Dwarf Elemental Elf Fairy Fey Genie Gnome Half-Dwarf Half-Elf Half-Orc Halfling Human Insectoid Orc Reptilian Robot Spirit Troll Vampire Werewolf).sample
    end
  end

  if template.include?('height')
    age == character_template.fetch(:age, 25)
    case age
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
    inches ||= rand(50..75) # here be dragons
    feet = inches / 12
    inches = inches % 12

    character_template[:height] = "#{feet} ft, #{inches} in"
  end

  if template.include?('job')
    character_template[:job] = Faker::Company.profession.capitalize 
    character_template[:dream_job] = Faker::Company.profession.capitalize
  end

  if template.include?('hobbies')
    hobbies = []
    3.times do
      hobbies << Faker::Hobby.activity
    end
    character_template[:hobbies] = hobbies.uniq.join(', ')
  end

  if template.include?('location')
    character_template[:country] = Faker::Address.country 
  end

  if template.include?('religion')
    # So many more at https://en.wikipedia.org/wiki/List_of_religions_and_spiritual_traditions
    # -- PR to Faker gem?
    character_template[:religion] = %w(Atheist Agnostic Undecided Syntheism Christianity Catholic Protestant Quaker Baptist Lutheranism Methodism Pentecostalism Unitarianism Calvanism Mormonism Paganism Druidism Wicca Scientology Mysticism Islam Hinduism Buddhism Shinto Taoism Vodou Hoodoo Sikhism Judaism Spiritism Shamanism Caodaism Confucianism Jainism Cheondoism Zoroastrianism Rastafari Pastafarianism Jediism Luciferianism Occultism Satanism Chrislam Witch).sample
  end

  if template.include?('languages')
    languages = [Faker::Nation.language]
    while rand(100) < 10
      languages << Faker::Nation.language
    end

    character_template[:other_languages_spoken] = languages.uniq.join(', ')
  end

  if template.include?('education')
    character_template[:highest_education_completed] = Faker::Demographic.educational_attainment

    case character_template[:highest_education_completed].split(' ').last.downcase
    when 'degree'
      character_template[:highest_education_completed] += " in #{Faker::Educator.subject} from #{Faker::Educator.university}"
    end
  end

  if template.include?('politics')
    character_template[:political_affiliation] = %w(Democrat Republican Liberal Conservative Libertarian Progressive Centrist Independent Socialist Communist Imperialist Nationalist Environmentalism Constitutionalist Paleoconservatism Reformist Radical\ Centrism Marxism–Leninism Anarchist Temperance Piracy Transhumanism Populism Nativism Distributism 	Neo-fascism Secularism Fiscal\ Conservatism Anarcho-socialism).sample

    if rand(100) < 5
      character_template[:political_affiliation] = 'Extremist ' + character_template[:political_affiliation]
    end
  end

  character_template[:favorite_book] = Faker::Book.title if template.include?('favorite-book')
  character_template[:favorite_author] = Faker::Book.author if template.include?('favorite-author')
  character_template[:favorite_genre] = Faker::Book.genre if template.include?('favorite-genre')
  character_template[:favorite_movie] = Faker::Movie.title if template.include?('favorite-movie')
  character_template[:favorite_artist] = Faker::Artist.name if template.include?('favorite-artist')
  character_template[:favorite_animal] = Faker::Creature::Animal.name.capitalize if template.include?('favorite-animal')
  character_template[:favorite_food] = Faker::Food.dish if template.include?('favorite-food')
  character_template[:favorite_quote] = "\"#{Faker::GreekPhilosophers.quote}\"" if template.include?('favorite-quote') 
  character_template[:superpower] = Faker::Superhero.power if template.include?('superpower')
  character_template[:blood_type] = Faker::Blood.group if template.include?('blood-type')

  character_template[:background] = character_background(character_template) if template.include?('background')

  # Unused:
  # Faker::Demographic.demonym => "Libyan"

  # Other generators:
  # (food) Faker::Food.description => "Creamy mascarpone cheese and custard layered between espresso and rum soaked house-made ladyfingers, topped with Valrhona cocoa powder."

  template_prelude = "Here's your generated character, #{event.interaction.user.mention}!\n\n"
  template_id = Time.now.to_i.to_s + '-' + event.interaction.user.username

  # Save this template in redis so we can look it up to generate new characters from later (which gets around storing the template in
  # discord's custom_id, which only allows 100 characters).
  @redis.set(template_id, template.join(','))

  event.respond(content: template_prelude + character_template.map { |key, value| "**#{key.to_s.gsub('_', ' ').capitalize}**: #{value}" }.join("\n")) do |_, view|
    view.row do |r|
      r.button(label: 'Generate another character with this template', style: :success, custom_id: 'reroll_character:' + template_id)
      r.button(label: 'Use a new template', style: :secondary, custom_id: 'character_template_builder')
    end
  end
end

def generate_creature(event:, template:)
  puts "Generating a creature [#{template.join(',')}] for #{event.interaction.user.username}"
  creature_template = {}
  creature_template[:name] = 'Creature name' if template.include?('name')

  template_prelude = "Here's your generated creature, #{event.interaction.user.mention}!\n\n"
  template_id = Time.now.to_i.to_s + '-' + event.interaction.user.username

  # Save this template in redis so we can look it up to generate new creatures from later (which gets around storing the template in
  # discord's custom_id, which only allows 100 characters).
  @redis.set(template_id, template.join(','))

  # Start by sending the creature image first, then the template.
  if template.include?('image')
    # So... apparently we need Python for anything HF-related because Ruby doesn't have a library for it.
    # So we'll just shell out to Python and let it do the work for us -- but we'll generate our prompt
    # here and set it in Redis so Python can pull it out to do the work.
    prompt = [
      "A #{Faker::Creature::Animal.name} mixed with a #{Faker::Creature::Animal.name}", 
      "rare undiscovered species of living in forest, photograph, masterpiece, trending on cgsociety, exotic, realistic rendering, fictional creature, alien, cinematic lighting, volumetric lighting, cinematic, fantasy art, detailed"
    ].join(', ')
    prompt_id = 'prompt-' + Time.now.to_i.to_s + '-' + event.interaction.user.username
    @redis.set(prompt_id, prompt)
    
    puts "Piping out to Python..."
    system("python3 generate-image-from-prompt.py #{prompt_id} #{prompt_id + '.png'}")
    
    puts "Back from Python..."

    if File.exist?("generated/#{prompt_id + '.png'}")
      puts "Image generated at generated/#{prompt_id + '.png'}"
    else
      puts "No file found at generated/#{prompt_id + '.png'}"
    end

    attachment = Discordrb::Attachment.new(
      File.open("generated/#{prompt_id + '.png'}", 'r'),
      'creature.png',
      File.extname("generated/#{prompt_id + '.png'}")
    )
  end

  event.respond(
    content: template_prelude + creature_template.map { |key, value| "**#{key.to_s.gsub('_', ' ').capitalize}**: #{value}" }.join("\n"),
    attachments: [attachment]
  ) do |_, view|
    view.row do |r|
      r.button(label: 'Generate another creature with this template', style: :success, custom_id: 'reroll_creature:' + template_id)
      r.button(label: 'Use a new template', style: :secondary, custom_id: 'creature_template_builder')
    end
  end

  # After sending the image, we should clean it up and delete our local copy so we don't fill up the server's disk.
  # sleep(5)
  # File.delete("pic.png")
end

bot = Discordrb::Bot.new(
  token: ENV.fetch('DISCORD_TOKEN'),
  intents: [:server_messages]
)

bot.register_application_command(:generate, 'Generators') do |generators|
  generators.subcommand(:character, 'Generate a filled-out character template')
  generators.subcommand(:creature, 'Generate a filled-out creature template')
end

def show_character_template_menu(event)
  character_generation_introduction = [
    "**Generate a filled-out character template**",
    "Howdy! Generating a character is easy. Just select what you'd like to know from the options below! (*Select as many as you'd like and don't forget you can scroll!*)"
  ]
  event.respond(content: character_generation_introduction.join("\n"), ephemeral: true) do |_, view|
    view.row do |r|
      r.select_menu(custom_id: 'generate_character', placeholder: 'Build your character template', min_values: 1, max_values: 25) do |s|
        s.option(label: 'Name', value: 'name')
        s.option(label: 'Archetype', value: 'archetype')
        s.option(label: 'Gender', value: 'gender')
        s.option(label: 'Age', value: 'age', description: "Will also generate a birthday")
        s.option(label: 'Ethnicity', value: 'ethnicity')
        s.option(label: 'Fantasy race', value: 'fantasy-race', description: 'Orcs, dwarves, angels, etc')
        s.option(label: 'Height', value: 'height')
        s.option(label: 'Appearance', value: 'appearance', description: "Generates build type, eye color, hair, and more")
        s.option(label: 'Alignment', value: 'alignment')
        s.option(label: 'Political affiliation', value: 'politics')
        s.option(label: 'Job', value: 'job')
        s.option(label: 'Hobbies', value: 'hobbies')
        s.option(label: 'Education', value: 'education')
        s.option(label: 'Location', value: 'location', description: "Just doing a country right now")
        s.option(label: 'Religion', value: 'religion')
        s.option(label: 'Favorite book', value: 'favorite-book')
        s.option(label: 'Favorite author', value: 'favorite-author')
#        s.option(label: 'Favorite genre', value: 'favorite-genre')
        s.option(label: 'Favorite movie', value: 'favorite-movie')
        s.option(label: 'Favorite artist', value: 'favorite-artist')
        s.option(label: 'Favorite animal', value: 'favorite-animal')
        s.option(label: 'Favorite food', value: 'favorite-food')
        s.option(label: 'Favorite quote', value: 'favorite-quote')
        s.option(label: 'Other languages spoken', value: 'languages')
        s.option(label: 'Superpower', value: 'superpower')
#        s.option(label: 'Blood type', value: 'blood-type')
        s.option(label: 'Background', value: 'background', description: "Work in progress!")
      end
    end
  end
end

def show_creature_template_menu(event)
  creature_generation_introduction = [
    "**Generate a creature**",
    "Generating a creature is a WIP. Right now, you can only generate a random creature's art."
  ]
  event.respond(content: creature_generation_introduction.join("\n"), ephemeral: true) do |_, view|
    view.row do |r|
      r.select_menu(custom_id: 'generate_creature', placeholder: 'Build your creature template', min_values: 1, max_values: 5) do |s|
        s.option(label: 'Name', value: 'name')
        s.option(label: 'Description', value: 'description')
        s.option(label: 'Image', value: 'image')
        s.option(label: 'Biome', value: 'biome')
        s.option(label: 'Taxonomy', value: 'taxonomy')
      end
    end
  end
end

bot.application_command(:generate).subcommand(:character) do |event|
  show_character_template_menu(event)
end

bot.application_command(:generate).subcommand(:creature) do |event|
  show_creature_template_menu(event)
end

bot.button(custom_id: 'character_template_builder') do |event|
  show_character_template_menu(event)
end

bot.button(custom_id: 'creature_template_builder') do |event|
  show_creature_template_menu(event)
end

bot.select_menu(custom_id: 'generate_character') do |event|
  generate_character(event: event, template: event.values)
end

bot.select_menu(custom_id: 'generate_creature') do |event|
  generate_creature(event: event, template: event.values)
end

bot.button(custom_id: /^reroll_character:/) do |event|
  template_id = event.interaction.button.custom_id.split(':').last
  attributes = @redis.get(template_id).split(',')

  generate_character(event: event, template: attributes)
end

bot.button(custom_id: /^reroll_creature:/) do |event|
  template_id = event.interaction.button.custom_id.split(':').last
  attributes = @redis.get(template_id).split(',')

  generate_creature(event: event, template: attributes)
end

bot.run
