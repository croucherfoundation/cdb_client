class Category
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/categories"

  def self.for_selection
    Category.all.sort_by(&:name).map{|cat| [cat.name, cat.code] }
  end
  
  def definite_name
    if name == name.pluralize
      "#{I18n.t(:the)} #{name}"
    else
      name
    end
  end

end
