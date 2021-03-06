# Consolidating the business of grant-having.

module HasGrant
  extend ActiveSupport::Concern

  included do
    scope :without_grant, -> { where('grant_id IS NULL OR grant_id = ""') }
    scope :for_grants, -> grant_ids { where(grant_id: grant_ids) }
  end

  def grant
    begin
      @grant ||= Grant.find(grant_id) if grant_id?
    rescue Her::Errors::Error
      nil
    end
  end
  
  def grant=(grant)
    if grant
      self.grant_id = grant.id
    else
      self.grant_id = nil
    end
    @grant = grant
  end
  
  def grant?
    grant_id? && !!grant.present?
  end
  
  def grant_type
    grant.grant_type if grant.present?
  end
  
  def grant_type_name
    grant_type.name if grant_type
  end
  
  def institutions
    grant.institutions if grant.present?
  end

end