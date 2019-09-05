class GrantType
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/grant_types"
  primary_key :code

  class << self
    def preload
      RequestStore.store[:grant_types] ||= self.all
    end

    def preloaded(code)
      RequestStore.store[:grant_types_by_code] ||= preload.each_with_object({}) do |awt, h|
        h[awt.code] = awt
      end
      RequestStore.store[:grant_types_by_code][code]
    end

    def for_selection
      GrantType.all.sort_by(&:name).map{|grt| [grt.short_name, grt.id] }
    end
  
    def new_with_defaults(attributes={})
      GrantType.new({
        name: "",
        code: nil,
        id_code: nil, #hack! to allow `code` to be set by user. All would be much easier if we used grant_type_id throughout.
        admin_code: "",
        page_collection_id: nil,
        round_type_name: nil,
        round_type_slug: nil,
        round_type_id: nil
      }.merge(attributes))
    end
  end

  def event_based?
    !!event_based
  end

  def to_param
    code
  end

end
