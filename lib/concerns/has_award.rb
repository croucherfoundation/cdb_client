# Consolidating the business of grant-having.

module HasAward
  extend ActiveSupport::Concern

  included do
    scope :without_award, -> { where('award_id IS NULL OR award_id = ""') }
  end

  def award
    Award.find(award_id) if award_id?
  end
  
  def award?
    award_id? && !!award
  end
  
  def award_type
    award.award_type if award
  end

end