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

    def create_entry(application_id:, field_type:, user_entered_name:, user_confirmed_name: nil, source_record_id: nil)
      create(
        application_id: application_id,
        field_type: field_type,
        user_entered_name: user_entered_name,
        user_confirmed_name: user_confirmed_name,
        source_record_id: source_record_id
      )
    end
  end
end
