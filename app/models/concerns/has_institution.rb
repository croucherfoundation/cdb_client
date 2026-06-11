# Consolidating the business of institution-having.

module HasInstitution
  extend ActiveSupport::Concern

  included do
    belongs_to :institution

    def institution
      Institution.find(institution_code) if institution_code.present?
    end

    def institution=(code)
      code = code.code if code.is_a? Institution
      self.institution_code = code
    end

    def institution_code=(value)
      if value.present? && value.to_s.start_with?('pending:')
        self.institution_name = value.sub('pending:', '')
      else
        super(value)
      end
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
      ccode = respond_to?(:from_country_code) && from_country_code.present? ? from_country_code : country_code
      if existing = Institution.where(name: name, country_code: ccode).first
        self.institution_code = existing.code
        self.pending_institution_name = nil if respond_to?(:pending_institution_name=)
      elsif match = find_institution_by_alias(name, ccode)
        self.institution_code = match.code
        self.pending_institution_name = nil if respond_to?(:pending_institution_name=)
      else
        self.institution_code = nil
        self.pending_institution_name = name if respond_to?(:pending_institution_name=)
      end
      @pending_institution_name = name if institution_code.blank?
    end
  end

  def institution_name
    if institution?
      institution.name
    else
      @pending_institution_name || (respond_to?(:pending_institution_name) && read_attribute(:pending_institution_name))
    end
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

  private

  def find_institution_by_alias(name, ccode)
    params = { q: name, show: 1 }
    params[:country_code] = ccode if ccode.present?
    results = Institution.where(params)
    return nil unless results.any?
    match = results.first
    match_name = match.name.to_s.downcase
    query_name = name.downcase.strip
    return match if match_name == query_name
    return match if match.respond_to?(:abbreviation) && match.abbreviation.to_s.downcase == query_name
    return match if match.respond_to?(:alias_names) && Array(match.alias_names).any? { |a| a.downcase == query_name }
    nil
  rescue StandardError
    nil
  end

end
