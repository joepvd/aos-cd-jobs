#!/usr/bin/env bats

source "${BATS_TEST_FILENAME%.bats}.sh"

@test "curl argument" {
  [[ "$(get_curl_arg 4.1-stable)" == "--data-urlencode 'in=>4.1.0-0 <4.2.0-0'" ]]
  [[ "$(get_curl_arg 4.9-stable)" == "--data-urlencode 'in=>4.9.0-0 <4.10.0-0'" ]]
  [[ "$(get_curl_arg 4.9-nightly)" == "" ]]
  [[ "$(get_curl_arg 4-stable)" == "" ]]
}

@test get_url {
  [[ "$(get_url 4.1-stable)" == "https://openshift-release.svc.ci.openshift.org/api/v1/releasestream/4-stable/latest" ]]
  [[ "$(get_url 4-stable)" == "https://openshift-release.svc.ci.openshift.org/api/v1/releasestream/4-stable/latest" ]]
  [[ "$(get_url 4.4-nightly)" == "https://openshift-release.svc.ci.openshift.org/api/v1/releasestream/4.4-nightly/latest" ]]
}

release_info='
{
  "name": "4.1.21",
  "pullSpec": "quay.io/openshift-release-dev/ocp-release:4.1.21",
  "downloadURL": "https://openshift-release-artifacts.svc.ci.openshift.org/4.1.21"
}'

@test get_pull_spec {
  [[ "$(get_pull_spec "$release_info")" == "quay.io/openshift-release-dev/ocp-release:4.1.21" ]]
  MIRROR=ocp-dev-preview
  [[ "$(get_pull_spec "$release_info")" == "quay.io/openshift-release-dev/ocp-release:4.1.21" ]]
}
