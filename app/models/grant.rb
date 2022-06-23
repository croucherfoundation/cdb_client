class Grant < ActiveResource::Base
  include HasGrantType
  include HasCountry
  include HasSecondCountry
  include HasInstitution
  include HasSecondInstitution
  include HasDirectors
  include CdbFormatApiResponse
  include CdbActiveResourceConfig

  has_many :projects
  # accepts_nested_attributes_for :projects

  def save
    self.prefix_options[:grant] = self.attributes
    super
  end

  def self.where(params = {})
    begin
      grants = find(:all, params: params)
    rescue => e
      Rails.logger.info "Awards Fetch Error: #{e}"
    end
    meta = CdbFormatApiResponse.meta
    return grants, meta
  end

  def self.new_with_defaults(attributes={})
    Grant.new({
      name: "",
      year: Date.today.year + 1,
      title: "",
      record_code: "",
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

  def projects
    Project.find(:all, params: {grant_id: self.id})
  end

  def approved?
    approved_at.present?
  end

  def approve(user=nil)
    self.approved_at ||= Time.now
    self.approved_by_uid ||= user.uid if user
  end

  def approve!(user=nil)
    self.approve
    self.save!
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

  ## CSV export

  def to_csv
    self.class.csv_columns.map {|col| self.send col.to_sym}
  end

  def self.csv_columns
    %w{id name record_code year application_id grant_type_code institution_code second_institution_code category_code country_code field description duration value expected_value begin_date expected_end_date director_uid codirector_uid terminated remarks payments}
  end

  def self.export_reports(params, csv, pdf, email)
    begin
      p = {search_params: params.to_s, csv: csv, pdf: pdf, email: email}
      find(:all, :from => :export_reports, params: p)
    rescue JSON::ParserError
      nil
    end
  end

end
