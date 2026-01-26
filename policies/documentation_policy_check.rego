# METADATA
# title: Documentation merged gate (PR-title scoped, skip if prod PR already merged)
# custom:
#   description: If there is an open production issue matching the current PR title and labeled DOCUMENTATION-REQUIRED, require a merged PR in the documentation repo with the same title. Skip enforcement if the production PR with this title is already merged.
#   priority: 1
#   predicateType: https://in-toto.io/attestation/test-result/v0.1
#   tags:
#   - ISO 27001
#   - A.8.4 Access to source code
#   complianceFrameworks:
#   - ISO 27001

package documentationMerged

import future.keywords.contains
import future.keywords.if
import future.keywords.in

productionRepo := data.production_repo
documentationRepo := data.documentation_repo
pullRequestTitle := data.pull_request_title

requiredLabel := "DOCUMENTATION-REQUIRED"
normalize_title(s) := lower(trim(s))

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
  normalize_title(iss.title) == normalize_title(pullRequestTitle)
}


merged_doc_prs contains doc_pr if {
  doc_pr := input[_]
  doc_pr.repository == documentationRepo
  is_merged_pr(doc_pr)
}

has_merged_docs_pr_with_title(title) if {
  some doc_pr in merged_doc_prs
  normalize_title(doc_pr.title) == normalize_title(title)
}


current_production_pr_merged if {
  some prod_pr in input
  prod_pr.repository == productionRepo
  is_pr(prod_pr)
  normalize_title(prod_pr.title) == normalize_title(pullRequestTitle)
  is_merged_pr(prod_pr)
}

# ---- output ----

failure_msg contains "input is empty" if {
  input == null
}

failure_msg contains "input is empty" if {
  input != null
  count(input) == 0
}

failure_msg contains msg if {
  msg := input
  msg == "Failed to fetch issues from repository" ||
  msg == "Rate Limit or Wrong Repository" ||
  msg == "Failed to read response body" ||
  msg == "Failed to unmarshal issues"
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
