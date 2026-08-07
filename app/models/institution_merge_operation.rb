class InstitutionMergeOperation
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/institution_merge_operations"

  class << self
    def start_merge(survivor_institution_code:, source_institution_codes:, performed_by_uid: nil, idempotency_key: nil)
      payload = {
        survivor_institution_code: survivor_institution_code,
        source_institution_codes: Array(source_institution_codes)
      }

      payload[:performed_by_uid] = performed_by_uid if performed_by_uid.present?
      payload[:idempotency_key] = idempotency_key if idempotency_key.present?

      post("/api/institution_merge_operations", payload)
    rescue JSON::ParserError
      nil
    end

    def undo(id, undone_by_uid: nil)
      payload = {}
      payload[:undone_by_uid] = undone_by_uid if undone_by_uid.present?

      post("/api/institution_merge_operations/#{id}/undo", payload)
    rescue JSON::ParserError
      nil
    end
  end
end