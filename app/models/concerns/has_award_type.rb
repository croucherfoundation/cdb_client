# Consolidating the business of grant-having.

module HasAwardType
  extend ActiveSupport::Concern

  included do
    scope :without_award_type, -> { where('award_type_code IS NULL OR award_type_code = ""') }
  end

  def award_type
    AwardType.find(award_type_code) if award_type_code?
  end
  
  def award_type?
    award_type_code? && award_type.present?
  end

end