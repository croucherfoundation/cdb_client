class Grant
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/grants"

  belongs_to :institution, foreign_key: :institution_code
  belongs_to :category, foreign_key: :category_code
  belongs_to :grant_type, foreign_key: :grant_type_code
  belongs_to :country, foreign_key: :country_code
  belongs_to :person, foreign_key: :person_uid

  after_save :decache

  def self.new_with_defaults(attributes={})
    Grant.new({
      name: "",
      title: "",
      grant_type_code: "",
      category_code: "",
      country_code: "",
      institution_code: "",
      year: Date.today.year
    }.merge(attributes))
  end

  def summary
    "##{record_no}: #{name} to #{person.name}"
  end
  
  def name_or_grant_type_name
    name.present? ? name : grant_type.name
  end

  def short_name_or_grant_type_name
    if name.present?
      name
    elsif grant_type
      grant_type.short_name
    else
      "Unknown grant type (#{id})"
    end
  end

  protected
  
  def decache(and_associates=true)
    if $cache
      path = self.class.collection_path
      $cache.delete path
      $cache.delete "#{path}/#{self.to_param}"
      self.person.send(:decache, false) if and_associates && self.person
    end
  end

end
