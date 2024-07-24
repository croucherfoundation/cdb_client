class StipendAllowanceType
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/stipend_allowance_types"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
    StipendAllowanceType.new({
        name: nil
      }.merge(attributes))
    end
  end
end
