package documentationMerged

import future.keywords.contains
import future.keywords.if
import future.keywords.in

productionRepo := data.production_repo
documentationRepo := data.documentation_repo
pullRequestTitle := data.pull_request_title

requiredLabel := "DOCUMENTATION-REQUIRED"
is_issue(obj) if { object.get(obj, "pull_request", null) == null }
is_pr(obj)    if { object.get(obj, "pull_request", null) != null }

is_merged_pr(obj) if {
  is_pr(obj)
  object.get(obj.pull_request, "merged_at", null) != null
}

has_label(obj, name) if {
  some i
  obj.labels[i].name == name
}

has_tag(obj, tag) if {
  some i
  obj.tags[i] == tag
}

documentation_required(obj) if { has_label(obj, requiredLabel) }
documentation_required(obj) if { has_tag(obj, requiredLabel) }

input_empty if { input == null }
input_empty if { input != null; count(input) == 0 }

production_pr_exists if {
  some obj in input
  obj.repository == productionRepo
  is_pr(obj)
  obj.title == pullRequestTitle
}

production_pr_merged if {
  some obj in input
  obj.repository == productionRepo
  is_merged_pr(obj)
  obj.title == pullRequestTitle
}

documentation_required_for_title if {
  some obj in input
  obj.repository == productionRepo
  is_issue(obj)
  obj.state == "open"
  obj.title == pullRequestTitle
  documentation_required(obj)
}

docs_merged_pr_exists_with_title if {
  some obj in input
  obj.repository == documentationRepo
  is_merged_pr(obj)
  obj.title == pullRequestTitle
}

failure_msg contains msg if {
  input_empty
  msg := "Policy error: input is empty (attestation/input JSON missing or unreadable)."
}

failure_msg contains msg if {
  not input_empty
  not production_pr_exists
  msg := sprintf(
    "Policy error: Production PR with title '%v' was not found in repo '%v' inside the input (wrong repo/fetch/attestation?).",
    [pullRequestTitle, productionRepo]
  )
}

failure_msg contains msg if {
  production_pr_exists
  not production_pr_merged

  documentation_required_for_title
  not docs_merged_pr_exists_with_title

  msg := sprintf(
    "Documentation PR missing: Production PR title '%v' in '%v' requires '%v', but no MERGED PR with the same title exists in docs repo '%v'.",
    [pullRequestTitle, productionRepo, requiredLabel, documentationRepo]
  )
}

explain := msg if {
  input_empty
  msg := "OK/INFO: Input is empty -> nothing to validate (check your attestation fetch)."
} else := msg if {
  not production_pr_exists
  msg := sprintf("OK/INFO: No production PR titled '%v' found in '%v' in input.", [pullRequestTitle, productionRepo])
} else := msg if {
  production_pr_merged
  msg := sprintf("OK: Production PR '%v' already merged in '%v' -> docs gate skipped.", [pullRequestTitle, productionRepo])
} else := msg if {
  production_pr_exists
  not documentation_required_for_title
  msg := sprintf("OK: No open production issue titled '%v' with label '%v' -> docs gate not required.", [pullRequestTitle, requiredLabel])
} else := msg if {
  documentation_required_for_title
  docs_merged_pr_exists_with_title
  msg := sprintf("OK: Docs requirement satisfied -> merged docs PR with title '%v' exists in '%v'.", [pullRequestTitle, documentationRepo])
} else := msg if {
  msg := sprintf(
    "ERROR: Docs required but missing merged docs PR for title '%v' (prod: '%v', docs: '%v').",
    [pullRequestTitle, productionRepo, documentationRepo]
  )
}
