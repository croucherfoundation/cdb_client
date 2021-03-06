class Grant
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/grants"

  belongs_to :director, foreign_key: :director_uid, class_name: "Person"
  belongs_to :codirector, foreign_key: :codirector_uid, class_name: "Person"
  belongs_to :grant_type, foreign_key: :grant_type_code
  belongs_to :country, foreign_key: :country_code
  belongs_to :institution, foreign_key: :institution_code
  belongs_to :second_country, foreign_key: :second_country_code, class_name: "Country"
  belongs_to :second_institution, foreign_key: :second_institution_code, class_name: "Institution"

  has_many :projects
  accepts_nested_attributes_for :projects
  sends_nested_attributes_for :projects

  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

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
    country.name if country.present?
  end

  def second_country_name
    second_country.name if second_country.present?
  end

  def institution_name
    institution.name if institution.present?
  end

  def second_institution_name
    second_institution.name if second_institution.present?
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
  
  def grant_type_short_name
    grant_type.short_name if grant_type
  end

end
