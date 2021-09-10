module HasDirectors
  extend ActiveSupport::Concern

  # Director should always be present
  #
  def director
    @director ||= Person.find(director_uid) if director_uid.present?
  end

  def director?
    director_uid.present? && director.present?
  end

  def director=(person)
    if person
      self.director_uid = person.uid
      @director = person
    else
      self.director_uid = nil
      @director = nil
    end
  end

  def director_attributes=(attributes={})
    if director?
      self.director.update(attributes)
      self.director.save
    end
  end

  # Codirector is optional but not unusual.
  #
  def codirector
    @codirector ||= Person.find(codirector_uid) if codirector_uid.present?
  end

  def codirector?
    codirector_uid.present? && codirector.present?
  end

  def codirector=(person)
    if person
      self.codirector_uid = person.uid
      @codirector = person
    else
      self.codirector_uid = nil
      @codirector = nil
    end
  end

  def codirector_attributes=(attributes={})
    if codirector?
      self.codirector.update(attributes)
      self.codirector.save
    end
  end

end
