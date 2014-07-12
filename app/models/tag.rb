class Tag
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/tags"

  def relative_ids
    parent_ids + child_ids
  end

  def self.for_selection
    all.map{ |t| [t.term, t.id] }
  end
  
  def self.from_terms(terms)
    if terms && terms.any?
      where(terms: terms)
    else
      []
    end
  end
  
  def self.all_terms
    all.map(&:term)
  end

  def self.lcsh_terms
    where(tag_type "LCSH").map(&:term)
  end
  
  def self.find_list(ids)
    where(ids: ids)
  end
  
  #TODO: try various cluster rules to find something simple that works most of the time.
  #
  def self.cluster_around(tags)
    tags.map {|t| [t.id] + t.parent_ids + t.child_ids }.flatten
  end
  
end
