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
    person_uid? && person.present?
  end
  
  def person=(person)
    if person
      self.person_uid = person.uid
      @person = person
    else
      self.person_uid = nil
      @person = nil
    end
  end

end