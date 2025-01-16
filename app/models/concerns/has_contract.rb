# Consolidating the business of grant-having.

module HasContract
  extend ActiveSupport::Concern

  included do
    belongs_to :contract

    def contract
      @contract ||= Contract.find(contract_id) if contract_id.present?
    end
  end

  def contract?
    contract_id.present? && contract.present?
  end

end
