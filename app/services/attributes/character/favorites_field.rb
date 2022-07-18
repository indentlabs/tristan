module Character
  class FavoritesField < Field
    field_key :favorites
  
    def self.value_for(template)
      {
        favorite_book:   Faker::Book.title,
        favorite_author: Faker::Book.author,
        favorite_genre:  Faker::Book.genre,
        favorite_movie:  Faker::Movie.title,
        favorite_artist: Faker::Artist.name,
        favorite_animal: Faker::Creature::Animal.name.capitalize,
        favorite_food:   Faker::Food.dish,
        favorite_quote:  "\"#{Faker::GreekPhilosophers.quote}\""
      }
    end
  end
end
