#!/usr/bin/env ruby
# Secret-free conventional commit header policy; no JS package manifest is needed.
require "json"
require "open3"
event = JSON.parse(File.read(ENV.fetch("GITHUB_EVENT_PATH")))
if ENV.fetch("GITHUB_EVENT_NAME") == "pull_request"
  pr = event.fetch("pull_request")
  abort "Foreign repository PR" unless pr.fetch("head").fetch("repo").fetch("full_name") == ENV.fetch("GITHUB_REPOSITORY")
  from = pr.fetch("base").fetch("sha")
  to = pr.fetch("head").fetch("sha")
else
  from = event.fetch("before")
  to = event.fetch("after")
end
abort "Invalid commit SHA" unless [from, to].all? { |sha| sha.match?(/\A[0-9a-f]{40}\z/) }
args = from == "0" * 40 ? ["-1", to] : ["#{from}..#{to}"]
output, status = Open3.capture2("git", "log", "--format=%s", *args, "--")
abort "Cannot read commit range" unless status.success?
invalid = output.lines.map(&:strip).reject do |header|
  header.match?(/\A(?:build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test|format)(?:\([^\r\n()]+\))?!?: .+\z/) ||
    header.start_with?("Merge ", "Revert ")
end
abort "Non-conventional commit headers: #{invalid.join('; ')}" unless invalid.empty?
puts "Conventional commit headers passed"
