# Consolidating the business of project-having.

module HasProject
  extend ActiveSupport::Concern

  included do
    belongs_to :project
    after_commit :reindex_project

    def project
      @project ||= Project.find(project_id) if project_id?
    end

    def project=(project)
      if project
        self.project_id = project.id
      else
        self.project_id = nil
      end
      @project = project
    end

    def reindex_project
      Project.reindex(project_id)
    end
  end

  def project?
    project_id? && !!project
  end

  def people
    project.people if project
  end

  def project_name
    project.name_or_grant_name if project
  end

  def project_institution_names
    project.institutions.map(&:name) if project
  end

  def project_person_mames
    project.people.map(&:name) if project
  end
end
