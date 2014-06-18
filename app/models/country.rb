class Country
  include PaginatedHer::Model
  use_api CDB
  collection_path "/api/countries"

  def self.for_selection
    countries = self.all.sort_by(&:name)
    likely_countries = countries.select {|c| c.likely? }
    options = likely_countries.map{ |c| [c.name, c.code] }
    options << ["------------", ""]
    options + countries.map{ |c| [c.name, c.code] }
  end

  def self.likely_for_selection
    likely.map{|c| [c.name, c.code] }
  end

  def self.active_for_selection
    active.map{|c| [c.name, c.code] }
  end
  
  def self.active
    self.where(active: true)
  end

  def self.likely
    self.where(likely: true)
  end

  def likely?
    !!likely && likely != 0
  end

end
