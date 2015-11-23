# Consolidating the business of institution-having.

module HasTwoInstitutions
  extend ActiveSupport::Concern

  included do
    scope :without_institution, -> { where('institution_code IS NULL OR institution_code = ""') }
    scope :with_institution, -> { where('institution_code IS NOT NULL AND institution_code <> ""') }
  end

  def institution
    # here we guess that it's probably going to be cheaper to get everything than to retrieve one at a time
    Institution.preloaded(institution_code) if institution_code?
  end
  
  def institution?
    institution_code? && institution
  end

  def institution_name
    if @institution_name.present?
      @institution_name
    elsif institution?
      institution.name
    end
  end
  
  def institution=(code)
    code = code.code if code.is_a? Institution
    self.institution_code = code
  end

  def institution_or_employer
    institution_name || employer
  end

  def institution_or_employer?
    institution? || employer?
  end

  def short_institution_or_employer
    institution? ? institution.short_name : employer
  end
  
  def institution_name=(name)
    if name.present?
      ccode = respond_to?(:from_country_code) ? from_country_code : country_code
      
      if existing = Institution.where(name: name, country_code: ccode).first
        self.institution_code = existing.code
      else
        created = Institution.create(name: name, country_code: ccode)
        self.institution_code = created.code
      end
    end
  end

  ## Second institution
  #
  # A second_institution_code column is required for these calls.
  #
  def second_institution
    Institution.preloaded(second_institution_code) if second_institution_code?
  end

  def second_institution?
    second_institution_code? && second_institution
  end

  def second_institution_name
    if @second_institution_name.present?
      @second_institution_name
    elsif second_institution?
      second_institution.name
    end
  end
  
  def second_institution=(code)
    code = code.code if code.is_a? Institution
    self.second_institution_code = code
  end
  
  def second_institution_name=(name)
    if name.present?
      if existing = Institution.where(name: name, country_code: second_country_code).first
        self.institution_code = existing.code
      else
        created = Institution.create(name: name, country_code: second_country_code)
        self.second_institution_code = created.code
      end
    end
  end

end