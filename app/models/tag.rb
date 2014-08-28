class Tag
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/tags"

  def relative_ids
    parent_ids + child_ids
  end

  def self.for_selection(count=nil)
    tags = count ? all(show: count) : all
    tags.map{ |t| [t.term, t.id] }
  end

  def self.scientific
    where(tag_type: "LCSH")
  end
  
  def self.scientific_selection
    scientific.map{ |t| [t.term, t.id] }
  end

  def self.administrative
    where(tag_type: "admin")
  end

  def self.administrative_selection
    administrative.map{ |t| [t.term, t.id] }
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
    find(ids)
  end
  
  #TODO: try various clustering rules to find something simple that works most of the time.
  #
  def self.cluster_around(tags)
    tags.map {|t| [t.id] + t.parent_ids + t.child_ids }.flatten
  end
  
  # Tree construction and traversal
  
  def self.tree_from(tag)
    json = tag.as_json
    json[:family_size] = 1
    if tag.child_ids.any?
      children = collected_tags.values_at(*tag.child_ids)
      if children && children.any?
        json[:children] = []
        children.each do |child|
          if child
            child_json = tree_from(child)
            json[:children].push child_json
            json[:family_size] += child_json[:family_size]
          end
        end
      end
    end
    json
  end
  
  def self.root
    where(term: "science").first
  end

  def self.tree
    tree_from(root)
  end
  
  def as_json(options={})
    json = {
      id: id,
      term: term,
      omitted: omitted?,
      branch_use: weight,
      use: taggings_count
    }
    json
  end
  
  # Tree manipulation
  # ...pretty basic to start with
  
  def omit!
    self.omitted = true
    self.save
  end
  
  def omit_children!
    self.omit_children = true
    self.save
  end
  
  protected
  
  # For tree-building and other assembly operations it's much more efficient to preload all the tags
  # and their links.
  #
  
  def self.collected_tags
    @tag_lookup ||= Tag.all.each_with_object({}) do |tag, hash|
      hash[tag.id] = tag
    end
  end

end
