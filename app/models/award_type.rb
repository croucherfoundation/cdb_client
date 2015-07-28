class AwardType
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/award_types"

  def self.for_selection
    AwardType.all.sort_by(&:name).map{|awt| [awt.short_name, awt.code] }
  end
end
