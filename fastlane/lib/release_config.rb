# Per-repository constants. This is the ONLY lib file that differs between repositories.
module ReleaseConfig
  APP_NAME = "InstantNX"
  REPOSITORY = "qtmleap/InstantNX"
  WORKFLOW = ".github/workflows/testflight.yaml"
  VERIFIED_SHA_ENV = "INSTANTNX_VERIFIED_SHA"
  VERIFIED_PR_ENV = "INSTANTNX_VERIFIED_PR"

  PROJECT = "InstantNX.xcodeproj"
  SCHEME = "InstantNX"
  TEAM_ID = "5Q94QJ7G98"
  MATCH_GIT_URL = "https://github.com/qtmleap/match.git"
  # Signing target => bundle identifier. The first entry is the app; the rest are embedded extensions.
  TARGETS = {
    "InstantNX" => "jp.qleap.instant-nx"
  }.freeze
  APP_TARGET = TARGETS.keys.first
  APP_IDENTIFIER = TARGETS.values.first
  EXTENSION_IDENTIFIERS = TARGETS.values.drop(1).freeze

  # A build number already used before CI existed; new numbers always exceed it.
  MINIMUM_BUILD = 0

  # Passed to upload_to_testflight (existing per-app behavior is preserved).
  UPLOAD = {
    skip_waiting_for_build_processing: true,
    notify_external_testers: true,
    expire_previous_builds: true
  }.freeze

  # Pinned sibling checkouts that the project references by relative path: name => revision.
  SIBLINGS = {

  }.freeze

  # Secret => file written (validated, never printed) into the temporary build copy only.
  SECRET_FILES = {

  }.freeze
  EXTRA_SECRETS = SECRET_FILES.keys.freeze

  # Trusted pull_request workflow runs and the job names that must succeed on the PR head.
  # Workflow paths and job names must match the workflows that actually run on pull_request.
  REQUIRED = {
    ".github/workflows/ios-ci.yaml" => ["Release Policy"]
  }.freeze
end
