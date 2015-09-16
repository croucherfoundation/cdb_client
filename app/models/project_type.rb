class ProjectType
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/project_types"

  def self.for_selection
    ProjectType.all.sort_by(&:name).map{|prt| [prt.name, prt.code] }
  end
  
  def self.default
    ProjectType.all.select{|pt| pt.default?}
  end
  
  def self.new_with_defaults(attributes={})
    ProjectType.new({
      name: "",
      code: "",
      description: "",
      default: false,
      expect_event: false
    }.merge(attributes))
  end
  
end