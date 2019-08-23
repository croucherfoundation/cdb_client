# Consolidating the business of institution-having.

module HasSecondInstitution
  extend ActiveSupport::Concern

  def second_institution
    # here we guess that it's probably going to be cheaper to get everything than to retrieve one at a time
    Institution.preloaded(second_institution_code) if second_institution_code.present?
  end
  
  def second_institution?
    second_institution_code.present? && second_institution.present?
  end

  def second_institution=(code)
    code = code.code if code.is_a? Institution
    self.second_institution_code = code
  end

  def second_institution_name=(name)
    if name.present?
      ccode = respond_to?(:from_country_code) ? from_country_code : country_code
      if existing = Institution.where(name: name, country_code: ccode).first
        self.second_institution_code = existing.code
      else
        created = Institution.create(name: name, country_code: ccode)
        self.second_institution_code = created.code
      end
    end
  end

  def second_institution_name
    second_institution.name if second_institution?
  end

  def second_institution_definite_name
    second_institution.definite_name if second_institution?
  end

  def second_institution_colloquial_name
    second_institution.colloquial_name if second_institution?
  end

end