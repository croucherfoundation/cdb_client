class Project
  include Her::JsonApi::Model
  include HasGrant

  use_api CDB
  collection_path "/api/projects"

  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    Project.new({
      name: "",
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
      featured: false,
      scientific_tags: "",
      admin_tags: ""
    }.merge(attributes))
  end

  def self.reindex(id)
    post "/api/projects/#{id}/reindex" if id.present?
  rescue => e
    puts "#{e}"
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

  def grant_type_code
    grant.grant_type_code if grant.present?
  end

  def institution
    grant.institution if grant.present?
  end

  def people
    if grant.present?
      grant.people
    else
      []
    end
  end

  def institutions
    if grant.present?
      grant.institutions
    else
      []
    end
  end

  def second_institution
    grant.second_institution if grant.present?
  end

  attr_accessor :eventful

  def eventful
    event_id.present? || !!@eventful
  end

  def should_have_event?
    grant.grant_type.event_based? if grant.present? && grant.grant_type
  end

  def grant_type_short_name
    grant.grant_type_short_name if grant.present?
  end

end
