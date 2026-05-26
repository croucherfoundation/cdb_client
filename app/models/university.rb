class University
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/universities"

  has_many :university_aliases

  class << self
    def preload
      RequestStore.store[:universities] ||= self.all
    end

    def preloaded(id)
      RequestStore.store[:universities_by_id] ||= preload.each_with_object({}) do |uni, h|
        h[uni.id] = uni
      end
      RequestStore.store[:universities_by_id][id]
    end

    def search(query, filters = {})
      params = { q: query }.merge(filters)
      where(params).all
    end

    def for_selection(country = nil)
      unis = country.present? ? where(country: country).all : preload
      unis.sort_by(&:canonical_name).map { |u| [u.canonical_name, u.id] }
    end
  end
end
