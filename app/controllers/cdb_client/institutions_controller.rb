module CdbClient
  class InstitutionsController < ApplicationController
    respond_to :json
    layout false
    before_filter :get_institutions, only: [:index]

    def index
      Rails.logger.warn "---> got #{@institutions.count}. Rendering."
      render json: @institutions
    end

    protected
  
    def get_institutions
      Rails.logger.warn "---> get institutions for #{params[:country_code]}"
      @institutions = Institution.for_selection(params[:country_code])
    end

  end
end