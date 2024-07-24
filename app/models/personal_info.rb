class PersonalInfo 
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/personal_info"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
      PersonalInfo.new({
        person_uid: nil,
        timezone: nil

      }.merge(attributes))
    end
  end

end