class Field
  def self.field_key(key)
    @key = key
  end
  def self.key
    @key
  end

  def self.depends_on(*fields)
    @dependencies = fields
  end

  def self.fill(template)
    # TODO first make sure all dependencies already exist in template values

    template.merge!(value_for(template))
  end
end
