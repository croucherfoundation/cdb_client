class Project
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/projects"

  belongs_to :grant
  has_many :siblings, class_name: "Project"
    
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
      year: nil,
      hidden: false,
      blacklisted: false,
      featured: false
    }.merge(attributes))
  end

  def people
    [director, codirector]
  end

  def name_or_grant_name
    if name.present?
      name
    elsif grant
      grant.name
    else
      "Unlinked Project"
    end
  end

  def institution
    grant.institution if grant
  end

  def institutions
    grant.institutions if grant
  end

  attr_accessor :eventful

  def eventful
    event_id.present? || !!@eventful
  end
  
  def grant_type_short_name
    grant.grant_type_short_name if grant
  end

end
