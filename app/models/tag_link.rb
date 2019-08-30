class TagLink
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/tag_links"

  def as_json(options={})
    {
      child_id: child_id,
      parent_id: parent_id
    }
  end
  
end
