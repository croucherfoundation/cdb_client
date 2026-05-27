module CdbClient
  class UniversitiesController < ApplicationController
    respond_to :json
    layout false
    skip_before_action :authenticate_user!, raise: false

    def search
      if params[:q].present? && params[:q].length >= 2
        @universities = University.search(params[:q], country: params[:country])
        render json: @universities.map { |u|
          { id: u.id, canonical_name: u.canonical_name, country: u.country }
        }
      else
        render json: []
      end
    end
  end
end
