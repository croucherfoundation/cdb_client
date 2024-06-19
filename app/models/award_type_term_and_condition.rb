class AwardTypeTermAndCondition 
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/award_type_term_and_conditions"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
    AwardTypeTermAndCondition.new({
      award_type_code: nil,
      term_and_condition_id: nil,
      custom_content: "",
      custom_content_enable: false,
      position: nil

    }.merge(attributes))
  end
  end

end