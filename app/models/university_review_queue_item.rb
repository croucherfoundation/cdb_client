class UniversityReviewQueueItem
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/university_review_queue"

  def application_university_entry
    data = attributes[:application_university_entry]
    return nil unless data.is_a?(Hash)
    OpenStruct.new(data)
  end

  class << self
    def pending
      where(status: "pending").all
    end

    def actionable
      where(status: ["pending", "in_progress"]).all
    end
  end
end
