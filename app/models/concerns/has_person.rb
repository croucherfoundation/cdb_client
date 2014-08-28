module HasPerson
  extend ActiveSupport::Concern

  included do
    scope :without_person, -> { where('person_uid IS NULL OR person_uid = ""') }
    scope :with_person, -> { where('person_uid IS NOT NULL AND person_uid <> ""') }
  end

  def person
    @person ||= Person.find(person_uid) if person_uid?
  end
  
  def person?
    person_uid? && !!person
  end
  
  def person=(uid)
    uid = uid.uid if uid.is_a? Person
    self.person_uid = uid
    @person = nil
  end

  # nested attribute support for our remote person object
  #
  def person_attributes=(attributes={})
    if person?
      Person.save_existing(person.id, attributes)
    end
  end

end