# Consolidating the business of grant-having.

module HasAward
  extend ActiveSupport::Concern

  included do
    belongs_to :award

    def award
      @award ||= Award.find(award_id) if award_id.present?
    end

    def award=(award)
      if award
        self.award_id = award.id
      else
        self.award_id = nil
      end
      @award = award
    end
  end

  def award?
    award_id.present? && award.present?
  end
  
  def award_type
    award.award_type if award.present?
  end

end