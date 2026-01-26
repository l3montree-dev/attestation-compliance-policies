package documentationMerged

import future.keywords.contains
import future.keywords.if
import future.keywords.in

productionRepo := data.production_repo
documentationRepo := data.documentation_repo
pullRequestTitle := data.pull_request_title

requiredLabel := "DOCUMENTATION-REQUIRED"

has_label(obj, name) if {
  some i
  obj.labels[i].name == name
}

has_tag(obj, tag) if {
  some i
  obj.tags[i] == tag
}

is_issue(obj) if {
  object.get(obj, "pull_request", null) == null
}

is_pr(obj) if {
  object.get(obj, "pull_request", null) != null
}

is_merged_pr(obj) if {
  is_pr(obj)
  object.get(obj.pull_request, "merged_at", null) != null
}

documentation_required(obj) if { has_label(obj, requiredLabel) }
documentation_required(obj) if { has_tag(obj, requiredLabel) }

matching_issues contains iss if {
  iss := input[_]
  iss.repository == productionRepo
  is_issue(iss)
  iss.state == "open"
  iss.title == pullRequestTitle
}

merged_doc_prs contains doc_pr if {
  doc_pr := input[_]
  doc_pr.repository == documentationRepo
  is_merged_pr(doc_pr)
}

has_merged_docs_pr_with_title(title) if {
  some doc_pr in merged_doc_prs
  doc_pr.title == title
}

current_production_pr_merged if {
  some prod_pr in input
  prod_pr.repository == productionRepo
  is_pr(prod_pr)
  prod_pr.title == pullRequestTitle
  is_merged_pr(prod_pr)
}

failure_msg contains "input is empty" if { input == null }

failure_msg contains "input is empty" if {
  input != null
  count(input) == 0
}

failure_msg contains msg if {
  not current_production_pr_merged
  some iss in matching_issues
  documentation_required(iss)
  not has_merged_docs_pr_with_title(pullRequestTitle)

  msg := sprintf(
    "Documentation required for PR '%v': matching issue #%v in %v is labeled %v, but no merged docs PR with the same title exists in %v.",
    [pullRequestTitle, iss.number, iss.repository, requiredLabel, documentationRepo]
  )
}
