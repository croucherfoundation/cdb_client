class Grant
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/grants"

  belongs_to :applicant, foreign_key: :applicant_uid, class_name: "Person"
  belongs_to :grant_type, foreign_key: :grant_type_code
  belongs_to :country, foreign_key: :country_code
  belongs_to :institution, foreign_key: :institution_code
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
      year: Date.today.year,
      title: "",
      description: "",
      field: "",
      field_chinese: "",
      application_id: nil,
      grant_type_code: "",
      country_code: "",
      institution_code: "",
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
      applicant_uid: "",
      projects: [],
      scientific_tag_ids: [],
      admin_tag_ids: []
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
  
  def institutions
    [institution, second_institution].compact
  end
  
  def any_institution?
    institution || second_institution
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

end
