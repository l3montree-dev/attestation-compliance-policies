# METADATA
# title: Current SBOM is present
# custom:
#   description: This policy checks if a current SBOM is present.
#   priority: 1
#   relatedResources:
#   - https://docs.example.com/policy/rule/E123
#   tags:
#   - ISO 27001
#   - A.5.7 Threat intelligence
#   - A.5.9 Inventory of information and other associated assets
#   - A.8.8 Management of technical vulnerabilities
#   complianceFrameworks:
#   - ISO 27001
package compliance

import rego.v1

default allow := false

# allow if {}
