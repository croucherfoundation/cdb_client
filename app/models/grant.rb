class Grant
  include Her::JsonApi::Model
  include HasGrantType
  include HasCountry
  include HasSecondCountry
  include HasInstitution
  include HasSecondInstitution
  include HasDirectors

  use_api CDB
  collection_path "/api/grants"

  has_many :projects
  accepts_nested_attributes_for :projects

  # temporary while we are not yet sending jsonapi data back to core as jsonapi
  include_root_in_json true
  parse_root_in_json false
  sends_nested_attributes_for :projects

  def self.new_with_defaults(attributes={})
    Grant.new({
      name: "",
      year: Date.today.year + 1,
      title: "",
      description: "",
      field: "",
      application_id: nil,
      grant_type_code: "",
      country_code: "",
      second_country_code: "",
      institution_code: "",
      show_second_institution: false,
      second_institution_code: "",
      institution_name: "",
      second_institution_name: "",
      begin_date: "",
      end_date: "",
      extension: "",
      duration: "",
      expected_value: "",
      approved_at: nil,
      approved_by_uid: nil,
      director_uid: nil,
      codirector_uid: nil,
      projects: [],
      scientific_tags: "",
      admin_tags: ""
    }.merge(attributes))
  end

  def approved?
    approved_at.present?
  end

  def approve!(user=nil)
    self.approved_at ||= Time.now
    self.approved_by_uid ||= user.uid if user
  end

  ## Duration and extension
  #
  def expected_end_date
    if end_date
      expected_end_date = Date.parse(end_date)
    elsif begin_date && duration
      expected_end_date = Date.parse(begin_date) + (duration * 12).to_i.months
      expected_end_date += extension.months if extended?
    end
    expected_end_date
  end

  def people
    [director, codirector].compact
  end

  def countries
    [country, second_country].compact
  end

  def institutions
    [institution, second_institution].compact
  end

  def any_institution?
    institution || second_institution
  end

  def country_name
    country.name if country?
  end

  def second_country_name
    second_country.name if second_country?
  end

  def institution_name
    institution.name if institution?
  end

  def second_institution_name
    second_institution.name if second_institution?
  end

  def project_word
    case grant_type_code
    when "asi", "csc"
      "course"
    when "cas"
      "laboratory"
    else
      "project"
    end
  end

  def build_project
    project = Project.new_with_defaults({
      grant_id: id,
      slug: year,
      description: description,
      begin_date: begin_date,
      end_date: end_date
    })
    projects << project
    project
  end

end
