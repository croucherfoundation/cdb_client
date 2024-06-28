class ExchangeRate
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/exchange_rates"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
      ExchangeRate.new({
        country_code: nil,
        rate: nil,
        year: nil
      }.merge(attributes))
    end
  end


end
