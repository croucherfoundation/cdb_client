class Tag
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/tags"

  class << self

    def preload
      @tags ||= self.all
    end

    def preloaded(code)
      @tags_by_code ||= preload.each_with_object({}) do |tag, h|
        h[tag.code] = tag
      end
      @tags_by_code[code]
    end
    
    def tags_by_id(id)
      @tags_by_id ||= preload.each_with_object({}) do |tag, h|
        h[tag.id] = tag
      end
      @tags_by_id
    end

    def find(id)
      preload.find{ |tag| tag.id == id }
    end
    
    def find_list(*ids)
      ids = [ids].flatten.map(&:to_i)
      preload.select{ |tag| ids.include?(tag.id.to_i) }
    end

    def from_term(term)
      preload.find{ |tag| tag.term == term }
    end

    def from_terms(terms)
      if terms && terms.any?
        preload.select{ |tag| terms.include?(tag.term) }
      else
        []
      end
    end

    def for_selection
      preload.sort_by(&:term).map{|t| [t.term, t.id] }
    end

    def scientific
      preload.select { |t| t.tag_type == "LCSH" }
    end
  
    def scientific_selection
      scientific.map{ |t| [t.term, t.id] }
    end

    def scientific_terms
      scientific.map(&:term)
    end

    def administrative
      preload.select { |t| t.tag_type == "admin" }
    end

    def administrative_selection
      administrative.map{ |t| [t.term, t.id] }
    end

    def administrative_terms
      administrative.map(&:term)
    end
  
    def all_terms
      preload.map(&:term)
    end

    def tree_from(tag)
      json = tag.as_json
      json[:family_size] = 1
      if tag.child_ids.any?
        children = tags_by_id.values_at(*tag.child_ids)
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
  
    def root
      from_term("science").first
    end

    def tree
      tree_from(root)
    end

    def cluster_around(tags)
      tags.map {|t| [t.id] + t.parent_ids + t.child_ids }.flatten
    end

  end

  def relative_ids
    parent_ids + child_ids
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

end
