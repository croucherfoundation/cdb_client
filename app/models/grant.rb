class Grant
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/grants"

  belongs_to :grant_type, foreign_key: :grant_type_code
  belongs_to :country, foreign_key: :country_code
  belongs_to :category, foreign_key: :category_code

  has_many :people
  has_many :institutions

  after_save :decache

  def self.new_with_defaults(attributes={})
    Grant.new({
      name: "",
      title: "",
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

  protected

  def decache
    $cache.flush_all if $cache
  end

end
