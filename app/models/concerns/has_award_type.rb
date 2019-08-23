# Consolidating the business of grant-having.

module HasAwardType
  extend ActiveSupport::Concern

  def award_type
    AwardType.find(award_type_code) if award_type_code?
  end
  
  def award_type?
    award_type_code? && award_type.present?
  end

end