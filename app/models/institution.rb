class Institution
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/institutions"

  belongs_to :country, foreign_key: :country_code

  class << self

    def for_selection(country_code=nil)
      if country_code.present?
        insts = self.where(:country_code => country_code)
      else
        insts = self.all
      end
      insts.sort_by(&:normalized_name).map{|inst| [inst.normalized_name, inst.code] }
    end

    def active_for_selection(country_code=nil)
      active(country_code).sort_by(&:normalized_name).map{|inst| [inst.colloquial_name, inst.code] }
    end
  
    def active(country_code=nil)
      if country_code.present?
        self.where(:country_code => country_code, active: true)
      else
        self.where(active: true)
      end
    end
  
    def new_with_defaults
      Institution.new({
        name: "",
        code: "",
        abbreviation: "",
        ugc_code: "",
        country_code: "",
        address: "",
        lat: "",
        lng: "",
        london: false,
        location_given: false
      })
    end
  end
  
  ## Output formatting
  #
  # The prepositionishness of names like 'University of Cambridge' requires us to prepend a 'the'
  # when in object position. Eg. 'studying at the University of Cambridge' vs. 'studying at Oxford University'.
  # 
  def definite_name(prefix="the")
    if name =~ /\b(of|for)\b/i
      "#{prefix} #{name}"
    else
      name
    end
  end

  def colloquial_name(prefix="the")
    if abbreviation?
      abbreviation
    else
      definite_name(prefix)
    end
  end
  
  def in_london?
    !!london && country_code == "GBR"
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

end
