# METADATA
# title: Build from signed source
# custom:
#   description: This policy checks if the build was done from a signed commit.
#   priority: 0
#   relatedResources:
#   - https://docs.example.com/policy/rule/E123
#   tags:
#   - ISO 27001
#   - A.8 Access Control
#   complianceFrameworks:
#   - ISO 27001
package compliance

import rego.v1

default allow := false

allow if {
	# make sure to look at the build definition to see if it was signed
	input.predicateType == "https://slsa.dev/provenance/v1"

	# signature needs to be defined on the external parameters
	input.predicate.buildDefinition.externalParameters.signature
}
