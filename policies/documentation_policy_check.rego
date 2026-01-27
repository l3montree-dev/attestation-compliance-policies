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


docs_pr_exists_with_title if {
  some obj in input
  obj.repository == documentationRepo
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
    "Documentation PR missing: For the Production PR title '%v' (%v), there is no MERGED PR with the same title in the docs repo %v.",
    [pullRequestTitle, productionRepo, documentationRepo]
  )
}

failure_msg contains msg if {
  not production_pr_exists
  msg := sprintf(
    "Production PR '%v' was not found in repo '%v' in the input (may indicate the wrong repo/fetch/attestation).",
    [pullRequestTitle, productionRepo]
  )
}