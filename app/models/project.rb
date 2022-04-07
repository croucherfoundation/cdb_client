class Project < ActiveResource::Base
  include FormatApiResponse
  include CdbActiveResourceConfig
  include HasGrant

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

  def self.where(params = {})
    begin
      projects = find(:all, params: params)
    rescue => e
      Rails.logger.info "Awards Fetch Error: #{e}"
    end
    meta = FormatApiResponse.meta

    return projects, meta
  end

  def save
    self.prefix_options[:project] = self.attributes
    super
  end

  def round
    @round ||= Round.find(round_id) if round_id.present?
  end

  def grant
    @grant ||= Grant.find(grant_id) if grant_id.present?
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
