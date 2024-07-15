class ImportantDate
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/important_dates"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
    ImportantDate.new({
      croucher_symposium_date: nil,
      croucher_award_ceremony_date: nil
      }.merge(attributes))
    end
  end
end
