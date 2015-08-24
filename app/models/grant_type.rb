class GrantType
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/grant_types"

  def self.for_selection
    GrantType.all.sort_by(&:name).map{|grt| [grt.short_name, grt.code] }
  end
  
  def self.new_with_defaults(attributes={})
    GrantType.new({
      name: "",
      code: "",
      page_collection_id: nil,
      round_type_id: nil
    }.merge(attributes))
  end
  
  def event_based?
    !!event_based
  end

end
