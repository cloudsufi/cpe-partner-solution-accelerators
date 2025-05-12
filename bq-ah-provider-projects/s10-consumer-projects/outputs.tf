output "provider_managed_projects" {
  value = var.provider_managed_projects
}

output "project_ids" {
  value = {
    for k, v in google_project.cx_projects :
    k => v.project_id
  }
}
