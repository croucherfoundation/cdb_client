class Country
  include PaginatedHer::Model
  use_api CDB

  def self.for_selection
    countries = self.all.sort_by(&:name)
    likely_countries = countries.select {|c| c.likely? }
    options = likely_countries.map{ |c| [c.name, c.code] }
    options << ["------------", ""]
    options + countries.map{ |c| [c.name, c.code] }
  end

  def self.likely_for_selection
    self.where(likely: true).map{|c| [c.name, c.code] }
  end

  def self.active_for_selection
    self.where(active: true).map{|c| [c.name, c.code] }
  end

  def likely?
    !!likely && likely != 0
  end

end
