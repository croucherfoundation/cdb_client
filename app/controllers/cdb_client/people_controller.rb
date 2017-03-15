module CdbClient
  class PeopleController < ApplicationController

    def suggest
      @people = Person.suggestions(match_params)
      # response is a minimal representation sufficient to build suggestions or show linkage
      render json: @people.map(&:as_json_for_suggestion)
    end

    protected

    def match_params
      params.require(:person).permit(:uid, :user_uid, :title, :family_name, :given_name, :email, :phone, :country_code, :institution_code)
    end

  end
end
