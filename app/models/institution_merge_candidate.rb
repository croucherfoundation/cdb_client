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

    # Opt-in grouped payload used by the next merge-review UI.
    #
    # Returns a plain Ruby hash payload (not Her model instances):
    # { contract_version:, data:, meta: }
    def grouped_pending(page: 1, show: 20, match_method: nil)
      grouped(status: "pending", page: page, show: show, match_method: match_method)
    end

    def grouped(status: nil, page: 1, show: 20, match_method: nil)
      token = ENV["UNIVERSITY_MATCHING_API_KEY"].presence || ENV["API_TOKEN"].presence

      response = Faraday.new(url: ENV["CORE_API_URL"]).get("/api/institution_merge_candidates") do |req|
        req.params["grouped"] = "true"
        req.params["status"] = status if status.present?
        req.params["match_method"] = match_method if match_method.present?
        req.params["page"] = page
        req.params["show"] = show
        req.headers["Accept"] = "application/json"
        req.headers["Authorization"] = "Bearer #{token}" if token.present?
      end

      body = response.body
      payload = body.is_a?(String) ? JSON.parse(body) : body
      payload.is_a?(Hash) ? payload : default_grouped_payload
    rescue JSON::ParserError, Her::Errors::ParseError, Faraday::Error => e
      Rails.logger.warn("[cdb_client] grouped institution_merge_candidates fetch failed: #{e.message}")
      default_grouped_payload
    end

    private

    def default_grouped_payload
      { "contract_version" => 1, "data" => [], "meta" => {} }
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
