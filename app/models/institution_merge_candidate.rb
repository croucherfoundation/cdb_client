class InstitutionMergeCandidate
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/institution_merge_candidates"

  class << self
    # The de-duplication job stages suggestions as "pending"; these are the ones
    # waiting for an administrator to merge or reject.
    def pending
      where(status: "pending").all
    end
  end

  # Record the admin's decision back in core once the duplicate has been merged
  # into the keeper institution.
  def mark_merged!
    update_status("merged")
  end

  # Record that the admin chose to keep both institutions separate.
  def reject!
    update_status("rejected")
  end

  private

  def update_status(new_status)
    self.status = new_status
    save
  end
end
