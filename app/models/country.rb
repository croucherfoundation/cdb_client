class Country
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/countries"
  primary_key :code

  class << self
    def preload
      RequestStore.store[:countries] ||= self.all.sort_by(&:name)
    end

    def preloaded(code)
      RequestStore.store[:countries_by_code] ||= preload.each_with_object({}) do |co, h|
        h[co.code] = co
      end
      RequestStore.store[:countries_by_code][code]
    end

    def for_selection
      options = likely_for_selection
      options << ["------------", "-"]
      options + preload.map{ |c| [c.name, c.code] }
    end

    def likely
      preload.select {|c| c.likely? }
    end

    def likely_for_selection
      likely.map{|c| [c.name, c.code] }
    end

    def active
      preload.select {|c| c.active? }
    end

    def active_for_selection
      active.map{|c| [c.name, c.code] }
    end
  end

  def likely?
    !!likely && likely != 0
  end

end
