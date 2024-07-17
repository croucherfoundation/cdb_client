class AwardStipendAllowance
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/award_stipend_allowances"
  include_root_in_json true
  parse_root_in_json false

  belongs_to :award
  belongs_to :award_type_stipend_allowance

  class << self
    def new_with_defaults(attributes={})
      AwardStipendAllowance.new({
        award_id: nil,
        award_type_stipend_allowance_id: nil,
        is_custom_allowance: false,
        custom_allowance_value: nil
      }.merge(attributes))
    end
  end
end
