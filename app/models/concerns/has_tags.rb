module HasTags
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggee, dependent: :destroy
  end

  def tags
    Tag.find_all(tag_ids)
  end

  def tag_ids
    taggings.map(&:tag_id)
  end

  def tags=(tags)
    tag_ids = tags.map(&:id)
  end
  
  def tag_ids=(tag_ids)
    Rails.logger.warn "==  tag_ids = #{tag_ids.inspect}"
    self.taggings.delete_all
    tag_ids.uniq.each do |id|
      taggings.create(tag_id: id) if id.present?
    end
  end
  
  def tagged?
    taggings.any?
  end

end