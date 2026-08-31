class ApplicationUniversityEntry
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/application_university_entries"

  include_root_in_json true
  parse_root_in_json false

  belongs_to :institution, foreign_key: :institution_code, primary_key: :code

  class << self
    def for_application(application_id)
      where(application_id: application_id).all
    end

    def create_entry(application_id:, field_type:, user_entered_name:, user_confirmed_name: nil, source_record_id: nil, institution_type: nil)
      create(
        application_id: application_id,
        field_type: field_type,
        user_entered_name: user_entered_name,
        user_confirmed_name: user_confirmed_name,
        source_record_id: source_record_id,
        institution_type: institution_type
      )
    end

    def update_entry(entry_id:, user_entered_name:, institution_type: nil)
      entry = find(entry_id)
      attributes = { user_entered_name: user_entered_name }
      attributes[:institution_type] = institution_type if institution_type.present?
      entry.assign_attributes(attributes)
      entry.save
    end
  end
end
