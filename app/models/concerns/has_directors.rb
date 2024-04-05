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

  def directors_attributes=(attributes={})
    if attributes['0'].present?
      if attributes.any?
        attributes.keys.each do |k|
          if attributes[k]['id'].present?
            v = attributes[k]
            if @director = Person.find(v['id'])
              @director.assign_attributes(v)
              @director.save
            end
          else
            person = create_person(attributes[k])
            if person.present?
              @director = Person.find(person.uid)
            end
          end
        end
      end
    else
      if attributes['id'].present? && @director = Person.find(attributes['id'])
        @director.assign_attributes(attributes)
        @director.save
      else
        person = create_person(attributes)
        if person.present?
          @director = Person.find(person.uid)
        end
      end
    end
    self.director_uids ||= []
    self.director_uids << @director.uid
    self.director_uids.uniq
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

  def codirectors_attributes=(attributes={})
    if attributes['0'].present?
      if attributes.any?
        attributes.keys.each do |k|
          if attributes[k]['id'].present?
            v = attributes[k]
            if @codirector = Person.find(v['id'])
              @codirector.assign_attributes(v)
              @codirector.save
            end
          else
            person = create_person(attributes[k])
            if person.present?
              @codirector = Person.find(person.uid)
            end
          end
        end
      end
    else
      if attributes['id'].present? && @codirector = Person.find(attributes['id'])
        @codirector.assign_attributes(attributes)
        @codirector.save
      else
        person = create_person(attributes)
        if person.present?
          @codirector = Person.find(person.uid)
        end
      end
    end
    self.codirector_uids ||= []
    self.codirector_uids << @codirector.uid
    self.codirector_uids.uniq
  end

  def create_person(attributes)
    person = Person.new(title: attributes['title'], given_name: attributes['given_name'], family_name: attributes['family_name'], country_code: attributes['country_code'], institution_code: attributes['institution_code'], institution_name: attributes['institution_name'], post: attributes['post'])
    person.save
  end

end
