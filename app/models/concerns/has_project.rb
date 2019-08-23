# Consolidating the business of project-having.

module HasProject
  extend ActiveSupport::Concern

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