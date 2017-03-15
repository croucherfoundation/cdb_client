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

    # tree_to gives us a nested object combining all the 
    # descents to all the given tags
    # `descent` is a simplification: one chain linking us back to one root node.
    # It ignores all the complexity of multiple parentage.
    # But this is enough to show a sunburst of broad to narrow tag attachment.
    #
    #
    def branch_to(tag)
      if parent = tags_by_id(tag.parent_ids.first)
        [tag, descent_to(parent)].flatten
      else
        [tag]
      end
    end

    def tree_to(terms)
      children = {}
      counts = {}
      tags = from_terms(terms)
      descents = tags.map {|t| branch_to(t) }

      tags.each do |t|
        counts[t.term] ||= 0
        counts[t.term] += 1
      end

      descents.each do |d|
        d.reverse!
        d.each_with_index do |t, i|
          parent = i > 0 ? d[i-1].term : 'root'
          children[parent] ||= []
          children[parent].push(t.term) unless children[parent].include?(t.term)
        end
      end
      branch_from('root', children, counts)
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

    def with_all_broader_terms(tags)
      
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
