# Consolidating the business of institution-having.

module HasInstitution
  extend ActiveSupport::Concern

  included do
    belongs_to :institution, optional: true

    def institution
      Institution.preloaded(institution_code) if institution_code.present?
    end

    def institution=(code)
      code = code.code if code.is_a? Institution
      self.institution_code = code
    end
  end
  
  def institution?
    institution_code.present? && institution.present?
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

  def institution_name
    institution.name if institution?
  end

  def institution_definite_name
    institution.definite_name if institution?
  end

  def institution_colloquial_name
    institution.colloquial_name if institution?
  end

  def location
    institution.location if institution?
  end

  def geojson_location
    institution.geojson_location if institution?
  end

end