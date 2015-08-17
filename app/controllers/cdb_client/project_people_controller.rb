module CdbClient
  class ProjectPeopleController < ApplicationController
    respond_to :html
    layout false

    def new
      @project_person = ProjectPerson.new_with_defaults
      respond_with @project_person
    end

  end
end