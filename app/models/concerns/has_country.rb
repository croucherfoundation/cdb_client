# Consolidating the business of country-having.

module HasCountry
  extend ActiveSupport::Concern

  included do
    scope :without_country, -> { where('country_code IS NULL OR country_code = ""') }
  end

  def country
    Country.find(country_code) if country_code?
  end
  
  def country?
    country_code? && !!country
  end
  
  def country=(country)
    if country
      self.country_code = country.code 
    else
      self.country_code = nil
    end
  end
  
  def country_name
    country.name if country
  end
    
end