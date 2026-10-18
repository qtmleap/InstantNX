require_relative "test_helper"
require "yaml"
require "open3"
require_relative "../lib/merge_verifier"

ROOT = File.expand_path("../..", __dir__)
EXPECTED_DOCUMENTS = %w[
  AGENTS.md CLAUDE.md README.md LICENSE
  .agents/skills/ios-development/SKILL.md
  .agents/skills/ios-development/references/app-review-followup.md
  .agents/skills/ios-development/references/release-policy.md
  .agents/skills/ios-development/references/testing-policy.md
  docs/development/ci-change-scope.md
  docs/development/ios-development-routine.md
].freeze

check "the native list is the exact reviewed finite document set" do
  assert NonReleaseDocuments::PATHS == EXPECTED_DOCUMENTS, NonReleaseDocuments::PATHS.inspect
  assert NonReleaseDocuments::PATHS.frozen? && NonReleaseDocuments::PATHS.uniq == NonReleaseDocuments::PATHS
  assert NonReleaseDocuments::PATHS.none? { |path| path.match?(/[*?\[\]{}]/) || path.end_with?("/") }
  assert NonReleaseDocuments::PATHS.none? { |path| path.start_with?(".github/", "fastlane/") }
end

check "every declared document exists in the repository" do
  missing = NonReleaseDocuments::PATHS.reject { |path| File.file?(File.join(ROOT, path)) }
  assert missing.empty?, missing.inspect
end

check "the TestFlight push filter lists exactly the native documents, preserving triggers" do
  workflow = YAML.safe_load(File.read(File.join(ROOT, ".github/workflows/testflight.yaml")), aliases: false)
  push = (workflow["on"] || workflow[true])["push"]
  assert push["paths-ignore"] == NonReleaseDocuments::PATHS, push["paths-ignore"].inspect
  assert push["branches"] == %w[develop master], push["branches"].inspect
  assert !push.key?("paths"), "push.paths would narrow the trigger"
  assert (workflow["on"] || workflow[true]).keys == ["push"], "unexpected extra trigger"
end

check "the CI change scope workflow stays free of the release exemption list" do
  text = File.read(File.join(ROOT, ".github/workflows/ci-change-scope.yaml"))
  assert !text.include?("paths-ignore")
end

# --- Real Git tree objects: no commits or network; native hooks stay enabled. ---
GIT_ENV = {
  "GIT_CONFIG_NOSYSTEM" => "1",
  "GIT_TERMINAL_PROMPT" => "0", "GIT_OPTIONAL_LOCKS" => "0"
}.freeze

def tree_git(dir, *args, stdin: nil)
  out, err, status = Open3.capture3(GIT_ENV, "git", "-C", dir, *args, stdin_data: stdin.to_s)
  raise "git #{args.first} failed: #{err}" unless status.success?
  out.strip
end

def write_tree(dir, files)
  Dir.children(dir).reject { |name| name == ".git" }.each { |name| FileUtils.rm_rf(File.join(dir, name)) }
  files.each do |path, body|
    FileUtils.mkdir_p(File.dirname(File.join(dir, path)))
    File.write(File.join(dir, path), body)
  end
  tree_git(dir, "add", "-A")
  tree_git(dir, "write-tree")
end

SOURCE_BODY = (1..40).map { |i| "line #{i} of an identical file\n" }.join

check "the exported Git adapter keeps both sides of an identical source-to-document rename" do
  Dir.mktmpdir("rename-safe-diff") do |dir|
    tree_git(dir, "init", "--quiet")
    before = write_tree(dir, "Sources/Moved.swift" => SOURCE_BODY, "Other.txt" => "x\n")
    after = write_tree(dir, "docs/development/ci-change-scope.md" => SOURCE_BODY, "Other.txt" => "x\n")
    adapter = MergeVerifier::Git.new(dir)
    paths = adapter.call("diff", "--name-only", "-z", before, after, "--").split("\0").sort
    assert paths == ["Sources/Moved.swift", "docs/development/ci-change-scope.md"], paths.inspect
    assert (paths - NonReleaseDocuments::PATHS).any?, "removed source path was lost"
    # Negative control: explicit rename detection collapses the pair to the destination only.
    detected = Open3.capture2(GIT_ENV, "git", "-C", dir, "diff", "--name-only", "-M", "-z", before, after, "--").first.split("\0")
    assert detected == ["docs/development/ci-change-scope.md"], detected.inspect
  end
end

check "the adapter leaves non-diff and already no-renames calls untouched, and still refuses Git errors" do
  recorder = Class.new do
    attr_reader :calls
    def call(*args)
      (@calls ||= []) << args
      "ok"
    end
  end
  recorder.prepend(NonReleaseDocuments::RenameSafeDiff)
  probe = recorder.new
  probe.call("rev-list", "--parents", "-n", "1", MERGE)
  probe.call("diff", "--name-only", "-z", "a", "b", "--")
  probe.call("diff", "--no-renames", "--name-only", "-z", "a", "b", "--")
  probe.call("diff", "--stat", "a", "b")
  assert probe.calls == [
    ["rev-list", "--parents", "-n", "1", MERGE],
    ["diff", "--no-renames", "--name-only", "-z", "a", "b", "--"],
    ["diff", "--no-renames", "--name-only", "-z", "a", "b", "--"],
    ["diff", "--stat", "a", "b"]
  ], probe.calls.inspect

  Dir.mktmpdir("rename-safe-diff-bad") do |dir|
    tree_git(dir, "init", "--quiet")
    adapter = MergeVerifier::Git.new(dir)
    error = error_of(MergeVerifier::Error) { adapter.call("diff", "--name-only", "-z", "f" * 40, "e" * 40, "--") }
    assert error, "a bad tree object did not raise the wrapped verifier error"
    missing = error_of(MergeVerifier::Error) { MergeVerifier::Git.new(File.join(dir, "absent")).call("diff", "--name-only", "-z", "a", "b", "--") }
    assert missing, "a missing repository did not raise the wrapped verifier error"
  end
end

finish
