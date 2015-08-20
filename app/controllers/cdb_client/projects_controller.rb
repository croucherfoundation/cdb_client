module CdbClient
  class ProjectsController < ApplicationController
    layout false

    def new
      @project = Project.new_with_defaults
      render
    end

  end
end