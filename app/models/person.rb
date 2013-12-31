class Person
  include HkNames
  
  include PaginatedHer::Model
  use_api CDB
  primary_key :uid

  has_many :awards
  has_many :tags
  has_many :notes
  belongs_to :country, foreign_key: :country_code

  def self.for_selection
    Person.all.sort_by(&:name).map{|p| [p.name, p.uid] }
  end
  
  def self.new_with_defaults
    Person.new({
      title: "",
      family_name: "",
      given_name: "",
      chinese_name: "",
      award_type_code: "",
      pob: "",
      dob: nil,
      post: "",
      department: "",
      employer: "",
      country_code: "HKG",
      email: "",
      phone: "",
      mobile: "",
      correspondence_address: "",
      hidden: false,
      blacklisted: false
    })
  end

  def invitable?
    email?
  end
  
  def to_param
    uid
  end

  def ias?
    !!ias
  end

  def srf?
    !!srf
  end

  def status
    if ias?
      "ias"
    elsif srf?
      "srf"
    else
      "scholar"
    end
  end
  
  def image
    images[:standard]
  end

  def thumbnail
    images[:thumbnail]
  end

  def icon
    images[:icon]
  end

end
