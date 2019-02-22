module CdbClient
  class CountriesController < ApplicationController
    respond_to :json
    layout false
    before_action :get_countries, only: [:index]

    def index
      render json: @countries
    end

    def timezones
      @country = Country.find(params[:country_code])
      render json: @country.timezones_for_selection
    end

    protected
  
    def get_institutions
      @countries = Country.all
    end

  end
end