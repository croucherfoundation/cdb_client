module CdbClient
  class InstitutionsController < ApplicationController
    respond_to :json
    layout false
    before_filter :get_institutions, only: [:index]

    def index
      render json: @institutions
    end

    protected
  
    def get_institutions
      @institutions = Institution.for_selection(params[:country_code])
    end

  end
end