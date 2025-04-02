# METADATA
# title: Software composition analysis executed
# custom:
#   description: This policy checks if software composition analysis was executed
#   priority: 1
#   relatedResources:
#   - https://docs.example.com/policy/rule/E123
#   tags:
#   - ISO 27001
#   - A.5.7 Threat intelligence
#   complianceFrameworks:
#   - ISO 27001
package compliance

import rego.v1

default allow := false

# allow if {}
