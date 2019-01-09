class Person
  include HkNames
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/people"
  primary_key :uid
  custom_get :suggest

  has_many :awards
  has_many :grants
  has_many :notes
  has_many :grants, foreign_key: :director_uid
  belongs_to :country, foreign_key: :country_code
  belongs_to :institution, foreign_key: :institution_code
  belongs_to :graduated_from, foreign_key: :graduated_from_code, class_name: "Institution"

  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

  class << self
    def for_selection
      Person.all(show: "all").sort_by(&:name).map{|p| [p.name, p.uid] }
    end

    def new_with_defaults(attributes={})
      Person.new({
        uid: nil,
        title: "",
        family_name: "",
        given_name: "",
        chinese_name: "",
        award_type_code: "",
        pob: "",
        dob: nil,
        post: "",
        department: "",
        institution_code: "",
        employer: "",
        country_code: "",
        hidden: false,
        blacklisted: false,
        featured: false,
        graduated_from_code: "",
        graduated_year: "",
        msc_year: "",
        mphil_year: "",
        phd_year: "",
        person_page_id: "",
        user_uid: "",
        institution: Institution.new_with_defaults,
        scientific_tags: "",
        admin_tags: ""
      }.merge(attributes))
    end

    def suggestions(params)
      if params[:uid]
        [self.find(params[:uid])]
      else
        self.suggest(params.to_h)
      end
    end
  end

  def latest_award
    awards.sort_by(&:date).last
  end

  def recent_award
    if award = latest_award
      if award.date && award.date > 3.months.ago
        award
      end
    end
  end

  def invitable?
    email?
  end

  def to_param
    uid
  end

  def ias?
    awards.any? { |a| a.award_type_code == 'ias'}
  end

  def srf?
    awards.any? { |a| a.award_type_code == 'srf'}
  end

  def status
    if srf?
      "srf"
    elsif ias?
      "ias"
    else
      "scholar"
    end
  end

  def image
    images[:standard]
  end

  def thumb
    images[:thumb]
  end

  def icon
    images[:icon]
  end

  def pronoun
    if gender? && gender == "f"
      I18n.t(:she)
    else
      I18n.t(:he)
    end
  end

  def whereabouts_explanation
    case whereabouts
    when "D" then "Due to start"
    when "S" then "Studying"
    when "C" then "Continued"
    when "K" then "Known"
    when "U" then "Unknown"
    else ""
    end
  end

  def self.whereabouts_options
    [
      ["Due to start", "D"],
      ["Studying", "S"],
      ["Continued", "C"],
      ["Known", "K"],
      ["Unknown","U"]
    ]
  end

  def graduated_from_name
    graduated_from.name if graduated_from.present?
  end

  def as_json_for_suggestion
    {
      uid: uid,
      user_uid: user_uid,
      title: title,
      given_name: given_name,
      family_name: family_name,
      email: email,
      phone: phone,
      colloquial_name: colloquial_name,
      formal_name: formal_name,
      country_code: country_code,
      institution_code: institution_code,
      situation: situation,
      icon: icon
    }
  end

  def self.relink_user(id,user_uid)
    begin
      patch "/api/people/#{id}/relink_user/#{user_uid}"
    rescue JSON::ParserError
      nil
    end
  end

end
