# Consolidating the business of grant-having.

module HasGrant
  extend ActiveSupport::Concern

  included do
    scope :without_grant, -> { where('grant_id IS NULL OR grant_id = ""') }
  end

  def grant
    @grant ||= Grant.find(grant_id) if grant_id?
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
    grant_id? && !!grant
  end
  
  def grant_type
    grant.grant_type if grant
  end
  
  def grant_type_name
    grant_type.name if grant_type
  end
  
  def institutions
    grant.institutions if grant
  end
  
  def people
    grant.people if grant
  end

end