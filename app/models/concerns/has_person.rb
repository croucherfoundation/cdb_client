module HasPerson
  extend ActiveSupport::Concern

  included do
    belongs_to :person, foreign_key: :person_uid

    def person
      @person ||= Person.find(person_uid) if person_uid.present?
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


  def person?
    person_uid.present? && person.present?
  end

  def person_name
    person.colloquial_name if person?
  end


  def person_attributes=(attributes={})
    if person?
      self.person.assign_attributes(attributes)
      self.person.save
    end
  end

  def relink_user(id,user_uid)
    Person.relink_user(id,user_uid)
  end

end
