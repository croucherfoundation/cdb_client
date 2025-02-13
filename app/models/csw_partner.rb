class CswPartner
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/csw_partners"

  class << self
    def new_with_defaults
      CswPartner.new({
        name: "",
        code: "",
        abbreviation: "",
        country_code: "",
        address: "",
        lat: "",
        lng: "",
        url: "",
        image: "",
        ugc_code: nil
      })
    end
   def find_by_code(code)
      where(code: code).first
    end
  end
end
