# Consolidating the business of grant-having.

module HasGrant
  extend ActiveSupport::Concern

  def grant
    @grant ||= Grant.find(grant_id) if grant_id.present?
  end

  def grant?
    grant_id.present? && grant.present?
  end

  def grant=(grant)
    if grant
      self.grant_id = grant.id
    else
      self.grant_id = nil
    end
    @grant = grant
  end

  def grant_type
    grant.grant_type if grant.present?
  end

  def grant_type_name
    grant_type.name if grant_type.present?
  end

  def institutions
    grant.institutions if grant.present?
  end

end