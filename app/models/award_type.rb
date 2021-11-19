class AwardType < ActiveResource::Base
  # include Her::JsonApi::Model

  self.site = ENV['CORE_API_URL']
  self.include_format_in_path = false

  # use_api CDB
  # collection_path "/api/award_types"
  # primary_key :code

  class << self

    def preload
      RequestStore.store[:award_types] ||= self.all
    end

    def preloaded(code)
      RequestStore.store[:award_types_by_code] ||= preload.each_with_object({}) do |awt, h|
        h[awt.code] = awt
      end
      RequestStore.store[:award_types_by_code][code]
    end

    def new_with_defaults(attributes={})
      AwardType.new({
        name: "",
        code: nil,
        id_code: nil, #hack! to allow `code` to be set by user. All would be much easier if we used award_type_id throughout.
        admin_code: "",
        round_type_name: nil,
        round_type_slug: nil,
        round_type_id: nil
      }.merge(attributes))
    end

    def for_selection
      preload.sort_by(&:name).map{|awt| [awt.short_name, awt.code] }
    end
  end

  def to_param
    code
  end

end
