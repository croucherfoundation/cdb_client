# Consolidating the business of country-having.

module HasSecondCountry
  extend ActiveSupport::Concern

  def second_country
    Country.preloaded(country_code) if country_code.present?
  end
  
  def second_country?
    country_code? && country.present?
  end
  
  def second_country=(country)
    if country
      self.second_country_code = country.code
    else
      self.second_country_code = nil
    end
  end
  
  def second_country_name
    second_country.name if second_country?
  end

end