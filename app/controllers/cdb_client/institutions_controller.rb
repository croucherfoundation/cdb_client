module CdbClient
  class InstitutionsController < ApplicationController
    respond_to :json
    layout false
    before_action :get_institutions, only: [:index]
    skip_before_action :authenticate_user!

    def index
      render json: @institutions
    end

    def suggest
      unless params[:name].blank?
        @institutions = Institution.where(institution_name: params[:name])
        render json: @institutions
      end
    end

    protected
  
    def get_institutions
      @institutions = Institution.for_selection(params[:country_code])
    end

  end
end