class UniversityReviewQueueItem
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/university_review_queue"

  belongs_to :application_university_entry

  class << self
    def pending
      where(status: "pending").all
    end

    def actionable
      where(status: ["pending", "in_progress"]).all
    end
  end
end
