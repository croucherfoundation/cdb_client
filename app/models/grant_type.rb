class GrantType
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/grant_types"
  primary_key :code

  def self.for_selection
    GrantType.all.sort_by(&:name).map{|grt| [grt.short_name, grt.id] }
  end
  
  def self.new_with_defaults(attributes={})
    GrantType.new({
      name: "",
      code: nil,
      id_code: nil,  #hack! to allow code to be set by user. TODO: use grant_type_id throughout
      admin_code: "",
      page_collection_id: nil,
      round_type_name: nil,
      round_type_slug: nil,
      round_type_id: nil
    }.merge(attributes))
  end
  
  def event_based?
    !!event_based
  end

  def to_param
    code
  end

end
