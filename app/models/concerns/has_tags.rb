module HasTags
  extend ActiveSupport::Concern

  included do
    attr_accessor :tag_ids_to_save
    has_many :taggings, as: :taggee, dependent: :destroy
    after_save :create_taggings
    
    scope :like, -> thing {
      if thing.tags.any?
        with_tags_like(thing.tags)
      else
        all
      end
    }

    scope :with_tags_like, -> tags {
      cluster_ids = Tag.cluster_around(tags)
      joins(:taggings).select("#{table_name}.*, count(taggings.id) as tagging_count").where(taggings: {tag_id: cluster_ids}).group("#{table_name}.id").having('count(taggings.id) > 0').order("tagging_count DESC")
    }
  end

  def tags
    if tag_ids.any?
      Tag.find_list(tag_ids)
    else
      []
    end
  end

  def tag_ids
    if new_record?
      self.tag_ids_to_save ||= []
    else
      @tag_ids ||= taggings.map(&:tag_id)
    end
  end
  
  def tag_names
    tags.map(&:term)
  end
  
  def add_tags(tags)
    self.tags = self.tags + [tags].flatten
  end

  def remove_tags(tags)
    self.tags = self.tags - [tags].flatten
  end

  def tags=(tags)
    self.tag_ids = tags.map(&:id)
  end
  
  def tag_ids=(tag_ids=[])
    if new_record?
      self.tag_ids_to_save = tag_ids
    else
      self.taggings.delete_all
      tag_ids.uniq.each do |id|
        p "#{self} taggings << #{id}"
        taggings.create(tag_id: id) if id.present?
      end
    end
  end
  
  def tag_names=(terms=[])
    self.tags = Tag.from_terms(terms)
  end
  
  def tagged?
    taggings.any?
  end
  
  protected
  
  def create_taggings
    if tag_ids_to_save
      self.tag_ids = tag_ids_to_save
    end
  end

end