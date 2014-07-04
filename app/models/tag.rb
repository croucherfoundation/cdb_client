class Tag
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/tags"
  
  def self.for_selection
    all.map{ |t| [t.term, t.id] }
  end
  
  def self.all_terms
    all.map(&:term)
  end

  def self.lcsh_terms
    where(tag_type "LCSH").map(&:term)
  end
  
  def self.find_all(ids)
    where(id: ids)
  end
end
