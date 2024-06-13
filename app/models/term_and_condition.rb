class TermAndCondition 
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/term_and_conditions"
  include_root_in_json true
  parse_root_in_json false

  has_many :award_type_term_and_conditions , class_name: "AwardTypeTermAndCondition"

  class << self
    def new_with_defaults(attributes={})
    TermAndCondition.new({
      name: "",
      default_content: ""
    }.merge(attributes))
  end
  end

end