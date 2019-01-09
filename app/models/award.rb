require 'csv'

class Award
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/awards"

  belongs_to :award_type, foreign_key: :award_type_code
  belongs_to :country, foreign_key: :country_code
  belongs_to :institution, foreign_key: :institution_code
  belongs_to :second_institution, foreign_key: :second_institution_code, class_name: "Institution"
  belongs_to :person, foreign_key: :person_uid

  accepts_nested_attributes_for :person
  sends_nested_attributes_for :person

  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    Award.new({
      name: "",
      title: "",
      description: "",
      record_no: "",
      record_code: "",
      application_id: nil,
      award_type_code: "",
      country_code: "",
      institution_code: "",
      second_institution_code: "",
      institution_name: "",
      second_institution_name: "",
      begin_date: "",
      extension: "",
      duration: "",
      approved_at: nil,
      approved_by_uid: nil,
      expected_value: "",
      year: Date.today.year,
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


  ## Helpers
  #
  # shortcut some of the if country then country.name boilerplate, which gets onerous
  # as here when everything is a string.
  #
  def summary
    "##{record_no}: #{name} to #{person.name}"
  end

  def country?
    country_code && !!country
  end
  
  def institution?
    institution_code? && !!institution
  end
  
  def second_institution?
    second_institution_code? && !!second_institution
  end

  def person?
    person_uid && !!person
  end
  
  def person_name
    person.colloquial_name if person?
  end

  def name_or_award_type_name
    name.presence || award_type_short_name
  end

  def country_name
    country.name if country.present?
  end

  def institution_name
    institution.name if institution?
  end

  def second_institution_name
    second_institution.name if second_institution?
  end

  def date
    Date.parse(begin_date) if begin_date?
  end

  ## Duration and extension
  #
  def extended?
    extended && extension?
  end
  
  ## CSV export
  
  def to_csv
    self.class.csv_columns.map {|col| self.send col.to_sym}
  end

  def self.csv_columns
    # %w{id record_no person_name year}
    %w{id record_no person_name year application_id award_type_name institution_name second_institution_name country_name name field description title person_uid supervisor supervisor_email supervisor_address department degree duration value expected_value uk begin_date expected_end_date completed end_date terminated terminated_date returned returned_date duration extended extension extension_end_date remarks payments bank green_form job_form progress_report_received progress_reports thesis_submitted thesis_url conference_grant_given conference_grant conference_report_received conference_report final_report_received final_report spouse_fee no_children leave}
  end

end
