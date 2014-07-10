class Award
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/awards"

  belongs_to :category, foreign_key: :category_code
  # belongs_to :award_type, foreign_key: :award_type_code
  belongs_to :country, foreign_key: :country_code
  belongs_to :person, foreign_key: :person_uid
  belongs_to :institution, foreign_key: :institution_code
  belongs_to :second_institution, foreign_key: :second_institution_code, class_name: "Institution"

  after_save :decache

  def self.new_with_defaults(attributes={})
    Award.new({
      name: "",
      title: "",
      record_no: "",
      record_code: "",
      application_id: nil,
      award_type_code: "",
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

  def summary
    "##{record_no}: #{name} to #{person.name}"
  end
  
  def name_or_award_type_name
    name.present? ? name : award_type.name
  end

  def short_name_or_award_type_name
    if name.present?
      name
    elsif award_type
      award_type.short_name
    else
      "Unknown award type (#{id})"
    end
  end

  ## Duration and extension
  #
  #
  def expected_end_date
    if completed && end_date
      expected_end_date = Date.parse(end_date)
    elsif begin_date && duration
      expected_end_date = Date.parse(begin_date) + (duration * 12).to_i.months - 1.day
      expected_end_date += extension.months if extended && extension
    end
    expected_end_date
  end
  
  def extended?
    
  end

  protected

  def decache
    $cache.flush_all if $cache
  end

end
