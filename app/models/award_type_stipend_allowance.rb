class AwardTypeStipendAllowance
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/award_type_stipend_allowances"
  include_root_in_json true
  parse_root_in_json false

  belongs_to :award_type
  belongs_to :stipend_allowance

  class << self
    def new_with_defaults(attributes={})
      AwardTypeStipendAllowance.new({
        award_type_code: nil,
        stipend_allowance_id: nil,
        is_custom_allowance: false,
        custom_allowance_value: nil,
        position: nil
      }.merge(attributes))
    end
  end
end
