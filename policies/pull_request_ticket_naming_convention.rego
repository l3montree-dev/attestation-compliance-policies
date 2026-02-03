 # METADATA
# title: PR must have matching ticket by title else the pipeline fails
# custom:
#   description: Fail if the current PR title has no equivalent ticket (issue) with the same title in a specific repository.
#   priority: 1
#   predicateType: https://in-toto.io/attestation/test-result/v0.1

package pr_title_ticket_gate

ticketRepo := data.ticket_repo
pullRequestTitle := data.pull_request_title

is_issue(x) if {
  object.get(x, "pull_request", null) == null
}

matching_issue_exists if {
  some x in input
  x.repository == ticketRepo
  is_issue(x)
  x.title == pullRequestTitle
}

failure_msg contains msg if {
  not matching_issue_exists
  msg := sprintf("No Issue with the title'%v' (PR-Title) in the Repository '%v' was found.", [pullRequestTitle, ticketRepo])
}