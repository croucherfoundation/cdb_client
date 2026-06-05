module CdbClient
  class InstitutionsController < ApplicationController
    respond_to :json
    layout false
    before_action :get_institutions, only: [:index]
    skip_before_action :authenticate_user!, raise: false

    def index
      render json: @institutions
    end

    def suggest
      unless params[:name].blank?
        query_params = { q: params[:name], show: (params[:limit] || 10).to_i }
        query_params[:country_code] = params[:country_code] if params[:country_code].present?
        @institutions = Institution.where(query_params)
        render json: @institutions.map(&:as_json_for_suggestion)
      end
    rescue StandardError => e
      Rails.logger.warn "Institution suggest search failed: #{e.message}"
      render json: []
    end

    protected
  
    def get_institutions
      whitelist = params[:whitelist] == 'true'
      insts = Institution.preload
      if params[:country_code].present?
        insts = insts.select { |inst| inst.country_code == params[:country_code] }
      end
      if params[:country_code] == 'HKG' && whitelist
        whitelist_hk_university = ['cuhk', 'cityu', 'eduhk', 'hkbu', 'hkis', 'hkmu', 'hkpu', 'hkust', 'ln', 'hku']
        insts = insts.select { |inst| whitelist_hk_university.include?(inst.code) }
      end
      @institutions = insts.sort_by(&:name).map { |inst| [inst.name, inst.code, Array(inst.try(:alias_names)).join('|')] }
    end    

  end
end