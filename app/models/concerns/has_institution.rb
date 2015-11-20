# Consolidating the business of institution-having.

module HasInstitution
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
      Rails.logger.warn ">> country_code: #{ccode})"
      
      if existing = Institution.where(name: name, country_code: ccode).first
        self.institution_code = existing.code
      else
        Rails.logger.warn ">> Institution.create(name: #{name}, country_code: #{ccode})"
        created = Institution.create(name: name, country_code: ccode)
        self.institution_code = created.code
      end
    end
  end

end