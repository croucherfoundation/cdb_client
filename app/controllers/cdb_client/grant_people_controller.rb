module CdbClient
  class GrantPeopleController < ApplicationController
    respond_to :html
    layout false

    def new
      @grant_person = GrantPerson.new_with_defaults
      respond_with @grant_person
    end

  end
end