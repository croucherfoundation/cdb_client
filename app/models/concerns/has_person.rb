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
  
  def person=(person)
    self.person_uid = person.uid
    @person = person
  end

  # nested attribute support for our remote person object
  #
  def person_attributes=(attributes={})
    if person?
      Person.save_existing(person.id, attributes)
    end
  end

end