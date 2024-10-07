module HasDirectors
  extend ActiveSupport::Concern

  # Director should always be present
  #
  def directors
    @directors ||= Person.find(director_uids) if director_uids.present?
  end

  def directors?
    director_uids.present? && directors.present?
  end

  def directors=(people)
    if people
      self.director_uids = people.map(&:uid)
      @directors = people
    else
      self.director_uids = nil
      @directors = nil
    end
  end

  def codirectors_attributes=(attributes={})
    assign_person_attributes('codirector', attributes)
  end

  def directors_attributes=(attributes={})
    assign_person_attributes('director', attributes)
  end

  def assign_person_attributes(type, attributes={})
    uids_field = "#{type}_uids"
    person_instance_var = "@#{type.singularize}"

    if multiple_person_attributes?(attributes)
      if attributes.any?
        attributes.keys.each do |k|
          if attributes[k]['id'].present?
            v = attributes[k]
            if instance_variable_set(person_instance_var, Person.find(v['id']))
              instance_variable_get(person_instance_var).assign_attributes(v)
              instance_variable_get(person_instance_var).save
            end
          else
            person = create_person(attributes[k])
            if person.present?
              instance_variable_set(person_instance_var, Person.find(person.uid))
            end
          end
        end
      end
    else
      if attributes['id'].present? && instance_variable_set(person_instance_var, Person.find(attributes['id']))
        instance_variable_get(person_instance_var).assign_attributes(attributes)
        instance_variable_get(person_instance_var).save
      else
        person = create_person(attributes)
        if person.present?
          instance_variable_set(person_instance_var, Person.find(person.uid))
        end
      end
    end

    self[uids_field] ||= []
    self[uids_field] << instance_variable_get(person_instance_var).uid
    self[uids_field].uniq!
  end

  def multiple_person_attributes?(attributes)
    attributes.is_a?(Hash) && attributes.keys.any? { |key| numeric_string?(key) }
  end

  def numeric_string?(key)
    key.to_s.match?(/^\d+$/)
  end

  # Codirector is optional but not unusual.
  #
  def codirectors
    @codirectors ||= Person.find(codirector_uids) if codirector_uids.present?
  end

  def codirectors?
    codirector_uids.present? && codirectors.present?
  end

  def codirectors=(people)
    if people
      self.codirector_uids = people.map(&:uid)
      @codirectors = people
    else
      self.codirector_uids = nil
      @codirectors = nil
    end
  end

  def create_person(attributes)
    person = Person.new(title: attributes['title'], given_name: attributes['given_name'], family_name: attributes['family_name'], country_code: attributes['country_code'], institution_code: attributes['institution_code'], institution_name: attributes['institution_name'], post: attributes['post'])
    person.save
  end

end
