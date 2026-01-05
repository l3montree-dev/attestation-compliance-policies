# METADATA
# title: Branch protection enabled
# custom:
#   description: This policy checks if documentation has already been merged, if not, it the check fails.
#   priority: 1
#   predicateType: https://in-toto.io/attestation/test-result/v0.1
#   relatedResources:
#   - https://docs.example.com/policy/rule/E123
#   tags:
#   - ISO 27001
#   - A.8.4 Access to source code
#   complianceFrameworks:
#   - ISO 27001


package documentationMerged

documentationRepo := data.documentation_repo 

failure_msg := "input is empty" if {
  input == null}
failure_msg := msg if {
  some i
  input[i].repository == documentationRepo
  input[i].pull_request.state != "closed"
  msg := sprintf("PR %v in %v is not closed yet!", [
    input[i].pull_request.number,
    input[i].repository,
  ])}

