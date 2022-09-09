class Institution
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/institutions"
  primary_key :code

  belongs_to :country, foreign_key: :country_code

  class << self

    def preload
      RequestStore.store[:institutions] ||= self.all
    end

    def preloaded(code)
      RequestStore.store[:institutions_by_code] ||= preload.each_with_object({}) do |inst, h|
        h[inst.code] = inst
      end
      RequestStore.store[:institutions_by_code][code]
    end

    def for_selection(country_code=nil, active_only=false)
      insts = preload
      if country_code.present?
        insts = insts.select {|inst| inst.country_code == country_code && (!active_only || inst.active?) }
      end
      insts.sort_by(&:normalized_name).map{|inst| [inst.normalized_name, inst.code] }
    end
    
    #NB this is a selection of likely partner institutions, not just everything in HK
    #
    def hk_for_selection
      insts = preload.select{|inst| inst.hk?}
      insts.sort_by(&:normalized_name).map{|inst| [inst.normalized_name, inst.code] }
    end

    def active_for_selection(country_code=nil)
      for_selection(country_code, true)
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
    if name =~ /\b(of|for)\b/i && self.name.split(" ").first.downcase != 'the'
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

  def located?
    lat.present? && lng.present?
  end

  def location
    { lat: lat.to_f, lng: lng.to_f } if located?
  end

  def geojson_location
    { lat: lat.to_f, lon: lng.to_f } if located?
  end

  def in_london?
    !!london && country_code == "GBR"
  end
  
  def image
    images[:standard] if images?
  end

  def thumb
    images[:thumb] if images?
  end

  def icon
    images[:icon] if images?
  end

  def self.extract_salient(string)
    string.gsub!(/\b(a|an|the)\b\s+/i, '')
    string.gsub!(/U\s+of\s+/i, '')
    string.gsub!(/University\s+of\s+/i, '')
    string.gsub!(/\s+University/i, '')
    string.gsub!(/\s+U$/i, '')
    string.gsub!(/\s+College/i, '')
    string
  end

end
