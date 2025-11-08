class Supervisor
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/supervisors"

  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    Supervisor.new({
      name: nil,
      department: nil,
      address: nil,
      email: nil,
      award_id: nil
    }.merge(attributes))
  end

end
