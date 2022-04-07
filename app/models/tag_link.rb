class TagLink < ActiveResource::Base

  def as_json(options={})
    {
      child_id: child_id,
      parent_id: parent_id
    }
  end

end
