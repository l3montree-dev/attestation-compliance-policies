package documentationMerged

import future.keywords.contains
import future.keywords.if
import future.keywords.in

productionRepo := data.production_repo
documentationRepo := data.documentation_repo
pullRequestTitle := data.pull_request_title

is_pr(obj) if {
  object.get(obj, "pull_request", null) != null
}

is_merged_pr(obj) if {
  is_pr(obj)
  object.get(obj.pull_request, "merged_at", null) != null
}

production_pr_exists if {
  some obj in input
  obj.repository == productionRepo
  is_pr(obj)
  obj.title == pullRequestTitle
}


docs_merged_pr_exists_with_title if {
  some obj in input
  obj.repository == documentationRepo
  is_merged_pr(obj)
  obj.title == pullRequestTitle
}

failure_msg contains msg if {
  production_pr_exists
  not docs_merged_pr_exists_with_title

msg := sprintf(
  "Documentation required for PR '%v': matching issue #%v in %v is labeled %v, but no merged documentation PR with the same title exists in %v.",
  [pullRequestTitle, iss.number, iss.repository, requiredLabel, documentationRepo]
)
  
}
