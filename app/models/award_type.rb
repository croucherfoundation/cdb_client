class AwardType
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/award_types"
  primary_key :code

  def self.for_selection
    AwardType.all.sort_by(&:name).map{|awt| [awt.short_name, awt.code] }
  end

  def to_param
    code
  end

end
