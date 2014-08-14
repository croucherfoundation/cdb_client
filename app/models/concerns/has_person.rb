module HasPerson
  extend ActiveSupport::Concern

  included do
    scope :without_person, -> { where('person_uid IS NULL OR person_uid = ""') }
    scope :with_person, -> { where('person_uid IS NOT NULL AND person_uid <> ""') }
  end

  def person
    Person.find(person_uid) if person_uid?
  end
  
  def person?
    person_uid? && !!person
  end
  
  def person=(uid)
    uid = uid.uid if uid.is_a? Person
    self.person_uid = uid
  end

  # nested attribute support for our remote person object
  #
  def person_attributes=(attributes={})
    Rails.logger.warn ">> person_attributes=(#{attributes.inspect})"
    if person?
      Rails.logger.warn ">> saving person"
      Person.save_existing(person.id, attributes)
      $cache.flush_all
    end
  end

end