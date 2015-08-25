# Consolidating the business of project-having.

module HasProject
  extend ActiveSupport::Concern

  included do
    scope :without_project, -> { where('project_id IS NULL OR project_id = ""') }
    scope :for_projects, -> project_ids { where(project_id: project_ids) }
  end

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

  def project?
    project_id? && !!project
  end

  def people
    project.people if project
  end

end