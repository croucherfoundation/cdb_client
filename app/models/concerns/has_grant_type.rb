# Consolidating the business of grant-type-having.

module HasGrantType
  extend ActiveSupport::Concern

  included do
    scope :without_grant_type, -> { where('grant_type_code IS NULL OR grant_type_code = ""') }
  end

  def grant_type
    GrantType.find(grant_type_code) if grant_type_code?
  end
  
  def grant_type?
    grant_type_code? && grant_type.present?
  end

  def grant_type_name
    grant_type.name if grant_type?
  end

  def grant_type_short_name
    grant_type.short_name if grant_type?
  end

end