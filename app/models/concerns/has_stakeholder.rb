# Consolidating the business of stakeholders-having.

module HasStakeholder
  extend ActiveSupport::Concern

  included do
    def event_manager
      @stakeholder ||= Stakeholder.where(event_outline_id: self.id, type: 'event_manager').first
    end
  end

  def event_manager?
    !!event_manager
  end

end
