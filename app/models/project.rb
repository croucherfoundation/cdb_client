class Project
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/projects"

  belongs_to :grant
  has_many :project_people
  accepts_nested_attributes_for :project_people
  sends_nested_attributes_for :project_people
  
  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    Project.new({
      name: "",
      year: "",
      slug: "",
      description: "",
      begin_date: "",
      end_date: "",
      grant_id: nil,
      event_id: nil,
      page_id: nil,
      round_id: nil,
      scientific_tag_ids: [],
      admin_tag_ids: [],
      project_people: [],
      project_people_attributes: [],
      year: Date.today.year
    }.merge(attributes))
  end

  def people
    project_people.map(&:person)
  end

  ## Tags are delivered from cdb as ids.
  #
  def scientific_tags
    Tag.find_list(scientific_tag_ids)
  end
  
  def scientific_tags=(tags)
    scientific_tag_ids = tags.map(&:id)
  end

  def admin_tags
    Tag.find_list(admin_tag_ids)
  end
  
  def admin_tags=(tags)
    admin_tag_ids = tags.map(&:id)
  end

  attr_accessor :eventful

  def eventful
    event_id.present? || !!@eventful
  end

end
