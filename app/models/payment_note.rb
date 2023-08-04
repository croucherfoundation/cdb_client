
class PaymentNote
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/payment_notes"

  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    PaymentNote.new({
      row_id: "",
      col_id: "",
      note: ""
    }.merge(attributes))
  end
end
