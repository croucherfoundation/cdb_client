class AwardTermAndCondition
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/award_term_and_conditions"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
      AwardTermAndCondition.new({
        award_id: nil,
        term_and_condition_id: nil,
        custom_content: ""
      }.merge(attributes))
    end
  end
end