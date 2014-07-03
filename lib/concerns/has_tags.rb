module HasTags
  extend ActiveSupport::Concern

  included do
    scope :tagged, { where.not(tags: nil)}
    scope :untagged, { where(tags: nil)}
  end

  def tags
    terms = tags.split(/,\s*/)
  end
  
  def tags=(terms)
    terms = [terms].flatten.compact.uniq
    
  end
  
  def add_tag(term)
    tags = tags + [term]
  end

  def remove_tag(term)
    tags = tags - [term]
  end

end