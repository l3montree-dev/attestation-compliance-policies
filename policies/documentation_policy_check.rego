# METADATA
# title: Documentation merged gate (PR-title scoped)
# custom:
#   description: If there is an open production-repo issue whose title matches the current PR title and has DOCUMENTATION-REQUIRED, require a merged PR in the documentation repo with the same title.
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

# The single "relevant" issue for THIS PR
matching_issue contains iss if {
    iss = input[_]
    iss.repository == productionRepo
    is_issue(iss)
    iss.state == "open"
    iss.title == pullRequestTitle
}

# Merged PRs in documentation repo
merged_doc_prs contains pr if {
    pr = input[_]
    pr.repository == documentationRepo
    is_merged_pr(pr)
}

has_merged_docs_pr_with_title(title) if {
    some pr in merged_doc_prs
    pr.title == title
}


failure_msg contains "input is empty" if {
    input == null
}

failure_msg contains msg if {
    some iss in matching_issue
    documentation_required(iss)
    not has_merged_docs_pr_with_title(pullRequestTitle)

    msg := sprintf(
        "Documentation required for PR '%v': matching issue #%v in %v is labeled %v, but no merged docs PR with the same title exists in %v.",
        [pullRequestTitle, iss.number, iss.repository, requiredLabel, documentationRepo]
    )
}