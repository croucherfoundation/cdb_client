class Tag
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/tags"
  
  def self.all_terms
    all.map(&:term)
  end

  def self.lcsh_terms
    where(tag_type "LCSH").map(&:term)
  end
end
