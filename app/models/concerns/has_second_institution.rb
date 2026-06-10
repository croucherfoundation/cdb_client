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
      ccode = respond_to?(:from_second_country_code) && from_second_country_code.present? ? from_second_country_code : second_country_code
      if existing = Institution.where(name: name, country_code: ccode).first
        self.second_institution_code = existing.code
        self.pending_second_institution_name = nil if respond_to?(:pending_second_institution_name=)
      elsif match = find_second_institution_by_alias(name, ccode)
        self.second_institution_code = match.code
        self.pending_second_institution_name = nil if respond_to?(:pending_second_institution_name=)
      else
        self.pending_second_institution_name = name if respond_to?(:pending_second_institution_name=)
      end
      @pending_second_institution_name = name if second_institution_code.blank?
    end
  end

  def second_institution_name
    if second_institution?
      second_institution.name
    else
      @pending_second_institution_name || (respond_to?(:pending_second_institution_name) && read_attribute(:pending_second_institution_name))
    end
  end

  def second_institution_definite_name
    second_institution.definite_name if second_institution?
  end

  def second_institution_colloquial_name
    second_institution.colloquial_name if second_institution?
  end

  private

  def find_second_institution_by_alias(name, ccode)
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