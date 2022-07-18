module Generators
  class Character
    def self.fill(attributes=[])
      generator = Generators::Character.new
      template  = Templates::Character.new

      filled_attributes = []
      attributes_queue = attributes

      while attributes_queue.any?
        # Only choose from attributes that can be computed now
        # fillable_candidates = attributes_queue.select(&:attribute.all_dependencies_met?)

        # Sort our candidates by least-first entropy
        # fillable_candidates.sort_by!(&:entropy)

        if fillable_candidates.empty?
          # error state -- handle this later!
        end

        # Fill the least-entropy attribute next
        # attribute = fillable_candidates.shift
        # template.send(attribute) = send(attribute).call(template)
        # attributes_queue.remove(attribute)
      end
    end

    #####################
    # Attribute fillers #
    #####################

    # meta-attributes for each field:
    # - requires: can't be computed until these fields are computed first
    # - depends_on: lists fields that should be computed first but don't HAVE to be
    fill :first_name do |template|
      depends_on :gender

      case template.fetch(:gender)
      when 'Male'
        Faker::Name.male_first_name
      when 'Female'
        Faker::Name.female_first_name
      else
        Faker::Name.first_name
      end
    end
  end
end


# class FirstNameAttribute < Attribute
#   depends_on :gender
#
#   def fill_for(template)
#   end

#   def entropy_score(template)
#   end
# end