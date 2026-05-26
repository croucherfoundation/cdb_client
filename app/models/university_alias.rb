class UniversityAlias
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/universities/:university_id/university_aliases"

  belongs_to :university
end
