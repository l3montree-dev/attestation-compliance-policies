# METADATA
# title: Code review for changes on default branch
# custom:
#   description: This policy checks if code review is performed for changes on the default branch.
#   priority: 1
#   relatedResources:
#   - https://docs.example.com/policy/rule/E123
#   tags:
#   - ISO 27001
#   - A.8.4 Access to source code
#   complianceFrameworks:
#   - ISO 27001
package compliance

import rego.v1

default allow := false

# allow if {}
