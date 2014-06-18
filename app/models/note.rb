class Note
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/notes"
  belongs_to :person, foreign_key: :person_uid

  after_save :decache
  after_destroy :decache

  def self.new_with_defaults(attributes={})
    self.new({
      title: "", 
      text: ""
    }.merge(attributes))
  end

  def date
    DateTime.parse(created_at)
  end

  protected

  def decache
    $cache.flush_all if $cache
  end

end
