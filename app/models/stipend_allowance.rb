class StipendAllowance
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/stipend_allowances"
  include_root_in_json true
  parse_root_in_json false

  belongs_to :stipend_allowance_type

  class << self
    def new_with_defaults(attributes={})
      StipendAllowance.new({
        stipend_allowance_type_id: nil,
        allowance_value: nil,
        year: nil,
        allowance_value_type: nil,
        is_per_annum: false
      }.merge(attributes))
    end
  end

end
