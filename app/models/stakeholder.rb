class Stakeholder
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/stakeholders"

  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    Stakeholder.new({
      title: nil,
      given_name: nil,
      family_name: nil,
      email: nil,
      event_outline_id: nil,
      user_uid: nil,
      stakeholder_type: nil
    }.merge(attributes))
  end

end
