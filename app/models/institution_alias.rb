class InstitutionAlias
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/institutions/:institution_code/institution_aliases"

  belongs_to :institution, foreign_key: :institution_code, primary_key: :code


  class << self
    def new_with_defaults(attributes={})
      InstitutionAlias.new({
        alias_name: nil,
        alias_type: nil
      }.merge(attributes))
    end
  end

end
