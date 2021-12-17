class Person < ActiveResource::Base
  include HkNames
  include HasCountry
  include HasInstitution
  include FormatApiResponse
  include ArConfig

  has_many :awards
  has_many :grants #, foreign_key: :director_uid
  has_many :cogrants #, class_name: "Grant", foreign_key: :codirector_uid
  has_many :notes
  # belongs_to :country, foreign_key: :country_code

  class << self
    def where(params = {})
      begin
        people = find(:all, params: params)
      rescue => e
        Rails.logger.info "People Fetch Error: #{e}"
      end
      meta = FormatApiResponse.meta
      # people = Kaminari.paginate_array(people).page(params[:page]).per(params[:show])
      return people, meta
    end

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
        invitable: false,
        hidden: false,
        blacklisted: false,
        featured: false,
        graduated_from_code: "",
        graduated_year: "",
        msc_year: "",
        mphil_year: "",
        phd_year: "",
        user_uid: "",
        institution: Institution.new_with_defaults,
        situation: "",
        scientific_tags: "",
        admin_tags: ""
      }.merge(attributes))
    end

    def suggestions(params)
      if params[:uid]
        [find(params[:uid])]
      else
        people = find(:all, :from => :suggest, params: params.to_h)
      end
    end

    def for_user(user)
      get "/api/people/user/#{user.uid}"
    rescue JSON::ParserError
      nil
    end
  end

  def save
    self.prefix_options[:person] = self.attributes
    super
  end

  def grants
    Grant.find(:all, params: {person_id: self.uid})
  end

  def latest_award
    awards.sort_by(&:year).last
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
    images.standard if images.present?
  end

  def thumb
    images.thumb if images.present?
  end

  def icon
    images.icon if images.present?
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

  def graduated_from
    Institution.preloaded(graduated_from_code) if graduated_from_code.present?
  end

  def graduated_from?
    graduated_from_code.present? && graduated_from.present?
  end

  def graduated_from=(code)
    code = code.code if code.is_a? Institution
    self.graduated_from_code = code
  end

  def graduated_from_name
    graduated_from.name if graduated_from?
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
