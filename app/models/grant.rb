class Grant
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/grants"

  belongs_to :grant_type, foreign_key: :grant_type_code
  belongs_to :country, foreign_key: :country_code
  belongs_to :category, foreign_key: :category_code
  belongs_to :institution, foreign_key: :institution_code
  belongs_to :second_institution, foreign_key: :second_institution_code, class_name: "Institution"

  has_many :people

  after_save :decache

  def self.new_with_defaults(attributes={})
    Grant.new({
      name: "",
      title: "",
      field: "",
      field_chinese: "",
      application_id: nil,
      grant_type_code: "",
      category_code: "",
      country_code: "",
      institution_code: "",
      second_institution_code: "",
      institution_name: "",
      second_institution_name: "",
      begin_date: "",
      extension: "",
      duration: "",
      person_uids: "",
      year: Date.today.year
    }.merge(attributes))
  end

  ## Duration and extension
  #
  #
  def expected_end_date
    if end_date
      expected_end_date = Date.parse(end_date)
    elsif begin_date && duration
      expected_end_date = Date.parse(begin_date) + (duration * 12).to_i.months
      expected_end_date += extension.months if extended? && extension
    end
    expected_end_date
  end
  
  def institutions
    [institution.fetch, second_institution.fetch].compact
  end

  protected

  def decache
    $cache.flush_all if $cache
  end

end