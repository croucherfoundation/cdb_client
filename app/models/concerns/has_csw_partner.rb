# Consolidating the business of institution-having.

module HasCswPartner
  extend ActiveSupport::Concern

  included do
    belongs_to :csw_partner
    accepts_nested_attributes_for :csw_partner

    def csw_partner
      CswPartner.find(csw_partner_id) if csw_partner_id.present?
    end

    def csw_partner=(csw_partner_id)
      csw_partner_id = csw_partner_id.csw_partner_id if csw_partner_id.is_a? CswPartner
      self.csw_partner_id = csw_partner_id
    end
  end
  
  def csw_partner?
    csw_partner_id.present? && csw_partner.present?
  end

  def csw_partner_name
    csw_partner.name if csw_partner?
  end

end