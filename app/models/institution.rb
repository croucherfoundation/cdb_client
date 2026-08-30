class Institution
  include Her::JsonApi::Model

  HK_UNIVERSITY_WHITELIST = %w[cuhk cityu eduhk hkbu hkis hkmu hkpu hkust ln hku].freeze

  use_api CDB
  collection_path "/api/institutions"
  primary_key :code

  belongs_to :country, foreign_key: :country_code
  has_many :institution_aliases

  class << self

    def preload(force_reload: false)
      if force_reload || RequestStore.store[:institutions].nil?
        if defined?(Rails) && Rails.respond_to?(:cache) && Rails.cache
          RequestStore.store[:institutions] = Rails.cache.fetch("cdb_client_institutions_all", expires_in: 30.minutes, force: force_reload) do
            self.all.to_a
          end
        else
          RequestStore.store[:institutions] = self.all.to_a
        end
      end
      RequestStore.store[:institutions]
    end

    def preloaded(code)
      RequestStore.store[:institutions_by_code] ||= preload.each_with_object({}) do |inst, h|
        h[inst.code] = inst
      end
      RequestStore.store[:institutions_by_code][code]
    end

    def for_selection(country_code=nil, active_only=false, whitelisted=false, options={})
      insts = preload
      exclude_codes = Array(options[:exclude_code]).compact
      
      if country_code.present?
        insts = insts.select do |inst|
          inst.country_code == country_code && (!active_only || inst.active?)
        end
      end

      if exclude_codes.present?
        insts = insts.reject { |inst| exclude_codes.include?(inst.code) }
      end

      if country_code == 'HKG' && whitelisted
        insts = insts.select { |inst| HK_UNIVERSITY_WHITELIST.include?(inst.code) }
      end

      insts.sort_by(&:name).map { |inst| [inst.name_with_location, inst.code] }
    end
    
    #NB this is a selection of likely partner institutions, not just everything in HK
    #
    def hk_for_selection
      insts = preload.select{|inst| inst.hk?}
      insts.sort_by(&:name).map{|inst| [inst.name_with_location, inst.code] }
    end

    def active_for_selection(country_code=nil)
      for_selection(country_code, true)
    end

    def new_with_defaults
      Institution.new({
        name: "",
        name_ch: "",
        code: "",
        institution_type: "university",
        abbreviation: "",
        short_name: "",
        ugc_code: "",
        city: "",
        admin_code: "",
        country_code: "",
        address: "",
        lat: "",
        lng: "",
        london: false,
        location_given: false,
        url: "",
        image: "",
        is_partner: false
      })
    end

    def duplicate_candidates(query, limit: 5)
      return [] if query.blank?

      token = ENV['UNIVERSITY_MATCHING_API_KEY'].presence || ENV['API_TOKEN'].presence

      connection = Faraday.new(url: ENV['CORE_API_URL'])
      response = connection.get('/api/institutions/duplicate_candidates') do |req|
        req.params['q'] = query
        req.params['limit'] = limit
        req.headers['Accept'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{token}" if token.present?
      end

      body = response.body
      return body if body.is_a?(Array)
      return JSON.parse(body) if body.is_a?(String)
      if body.is_a?(Hash)
        return body['duplicate_candidates'] || body[:duplicate_candidates] || body['data'] || []
      end

      Array(body)
    rescue JSON::ParserError, Her::Errors::ParseError, Faraday::Error => e
      Rails.logger.warn("[cdb_client] duplicate_candidates failed for #{query.inspect}: #{e.message}")
      []
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
  
  def as_json_for_suggestion
    {
      code: id,
      name: name
    }
  end

  def get_scholar_count
    code.present? ? Person.where(institution_code: code).count : 0
  end

end
