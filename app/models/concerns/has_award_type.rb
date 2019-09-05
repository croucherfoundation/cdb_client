# Consolidating the business of grant-having.

module HasAwardType
  extend ActiveSupport::Concern

  included do
    belongs_to :award_type
  end

  def award_type
    AwardType.preloaded(award_type_code) if award_type_code.present?
  end
  
  def award_type?
    award_type_code? && award_type.present?
  end

  def award_type_name
    award_type.name if award_type?
  end

  def award_type_short_name
    award_type.short_name if award_type?
  end

end