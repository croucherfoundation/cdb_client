
class PaymentCategory
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/payment_categories"

  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    PaymentCategory.new({
      header_type: "",
      header_name: "",
      is_calculate: ""
    }.merge(attributes))
  end

  def self.gengrate_default_payment_note(award_id)
    get "/api/payment_categories/gengrate_default_payment_note/#{award_id}"
  rescue JSON::ParserError
    nil
  end

  def self.get_award_payment_note(award_id)
    get "/api/payment_categories/get_award_payment_note/#{award_id}"
  rescue JSON::ParserError
    nil
  end
end
