# Consolidating the business of institution-having.

module HasInstitution
  extend ActiveSupport::Concern

  included do
    scope :without_institution, -> { where('institution_code IS NULL OR institution_code = ""') }
  end

  def institution
    Institution.find(institution_code) if institution_code?
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
      country_code = respond_to?(:from_country_code) ? from_country_code : country_code
      if existing = Institution.where(name: name, country_code: country_code).first
        self.institution_code = existing.code
      else
        created = Institution.create(name: name, country_code: country_code)
        self.institution_code = created.code
        $cache.flush_all #rough!
      end
    end
  end

end