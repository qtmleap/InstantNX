# Exact, finite list of documentation files that never change a shipped build. This is the single
# native list: no globs, directories, source/build/CI/dependency paths or extension-wide exemptions.
# The TestFlight push workflow lists the same paths literally under `on.push.paths-ignore`;
# fastlane/test/non_release_documents_test.rb keeps the two in sync.
module NonReleaseDocuments
  PATHS = %w[
    AGENTS.md
    CLAUDE.md
    README.md
    LICENSE
    .agents/skills/ios-development/SKILL.md
    .agents/skills/ios-development/references/app-review-followup.md
    .agents/skills/ios-development/references/release-policy.md
    .agents/skills/ios-development/references/testing-policy.md
    docs/development/ci-change-scope.md
    docs/development/ios-development-routine.md
  ].freeze

  # Prepended to the exported MergeVerifier::Git. Git's default rename detection reports only the
  # destination of a rename, so a source file renamed to an identical document would look
  # documentation-only. `--no-renames` keeps both the removed and the added path in the checked diff.
  module RenameSafeDiff
    def call(*args)
      args = [args.first, "--no-renames", *args.drop(1)] if args.first == "diff" && args.include?("--name-only") && !args.include?("--no-renames")
      super(*args)
    end
  end
end
