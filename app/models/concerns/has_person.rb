module HasPerson
  extend ActiveSupport::Concern

  included do
    scope :without_person, -> { where('person_uid IS NULL OR person_uid = ""') }
    scope :with_person, -> { where('person_uid IS NOT NULL AND person_uid <> ""') }
  end

  def person
    begin
      @person ||= Person.find(person_uid) if person_uid?
    rescue Her::Errors::Error
      nil
    end
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

  def person_attributes=(attributes={})
    if person?
      self.person.update_attributes(attributes)
      self.person.save
    end
  end

end