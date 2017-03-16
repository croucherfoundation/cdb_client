class AwardType
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/award_types"
  primary_key :code

  def self.new_with_defaults(attributes={})
    AwardType.new({
      name: "",
      code: nil,
      id_code: nil,  #hack! to allow code to be set by user. TODO: use award_type_id throughout
      admin_code: "",
      round_type_name: nil,
      round_type_slug: nil,
      round_type_id: nil
    }.merge(attributes))
  end

  def self.for_selection
    AwardType.all.sort_by(&:name).map{|awt| [awt.short_name, awt.code] }
  end

  def to_param
    code
  end

end
