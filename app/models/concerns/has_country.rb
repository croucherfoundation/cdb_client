# Consolidating the business of country-having.

module HasCountry
  extend ActiveSupport::Concern

  included do
    belongs_to :country

    def country
      Country.preloaded(country_code) if country_code.present?
    end

    def country=(country)
      if country
        self.country_code = country.code
      else
        self.country_code = nil
      end
    end
  end

  def country?
    country_code? && country.present?
  end

  def country_name
    country.name if country?
  end

end