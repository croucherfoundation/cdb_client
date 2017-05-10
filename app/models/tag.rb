class Tag
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/tags"

  class << self

    def preload
      RequestStore.store[:tags] ||= self.all
    end

    def preloaded(code)
      RequestStore.store[:tags_by_code] ||= preload.each_with_object({}) do |tag, h|
        h[tag.code] = tag
      end
      RequestStore.store[:tags_by_code][code]
    end
    
    def tags_by_id(id)
      RequestStore.store[:tags_by_id] ||= preload.each_with_object({}) do |tag, h|
        h[tag.id] = tag
      end
      RequestStore.store[:tags_by_id]
    end

    def find_with_preload(id)
      preload.find{ |tag| tag.id == id }
    end
    
    def find_list(*ids)
      ids = [ids].flatten.map(&:to_i)
      find(ids)
    end

    def find_list_with_preload(*ids)
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

    # tree_to gives us a nested object combining all the descents to all the given tags.
    # This is much simpler than it used to be: the API now delivers each tag with its
    # shortest descent precomputed.
    # It's still a simplification and there are many more possible chains of parentage,
    # but it's enough for visualisation purposes.
    #
    # Here we return terms, not tags.
    #
    def branch_to(tag)
      tag.descent.split(',')
    end

    def branches_to(terms)
      terms = terms.split(/,\s*/) if terms.is_a?(String)
      from_terms(terms).map(&:descent).map{|d| d.split(',')}
    end

    def tree_to(terms)
      children = {}
      counts = {}

      terms.each do |t|
        counts[t] ||= 0
        counts[t] += 1
      end

      descents = branches_to(terms)
      descents.each do |d|
        d.reverse!
        previous_term = 'root'
        d.each do |t, i|
          children[previous_term] ||= []
          children[previous_term].push(t) unless children[previous_term].include?(t)
          previous_term = t
        end
      end
      build_tree_from('root', children, counts)
    end

    # build_tree_from takes a root node and prepared lookup tables for children and counts,
    # and descends recursively from the route by way of the children to create a tree of the counts.
    #
    def build_tree_from(term, children, counts)
      node = {
       "name": term,
       "count": counts[term] || 0
      }
      if children[term]
        node['children'] = children[term].map {|t| build_tree_from(t, children, counts) }
      end
      node
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
