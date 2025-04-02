# METADATA
# title: No violation against license allow list
# custom:
#   description: This policy checks if there is no violation against the license allow list.
#   priority: 1
#   relatedResources:
#   - https://docs.example.com/policy/rule/E123
#   tags:
#   - iso27001
#   - A.5.32 Intellectual property rights
#   complianceFrameworks:
#   - iso27001
package compliance

import rego.v1

default allow := false

# allow if {}
