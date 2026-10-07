#!/usr/bin/env ruby
require "xcodeproj"
require "json"
require "rexml/document"
ROOT = File.expand_path("..", __dir__)
NAME = "InstantNX"
BUNDLE = "jp.qleap.instant-nx"
def check(value, message)
  abort message unless value
end
project = Xcodeproj::Project.open(File.join(ROOT, "#{NAME}.xcodeproj"))
app = project.targets.find { |target| target.name == NAME }
check(app && app.product_type == "com.apple.product-type.application", "App identity mismatch")
check(project.targets.map(&:name).sort == [NAME, "#{NAME}Tests", "#{NAME}UITests"].sort, "Target inventory mismatch")
(project.build_configurations + project.targets.flat_map(&:build_configurations)).each do |config|
  check(config.build_settings["DEVELOPMENT_TEAM"] == "5Q94QJ7G98", "Team mismatch")
  check(config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] == "16.0", "Deployment target mismatch")
end
app.build_configurations.each do |config|
  check(config.build_settings["MARKETING_VERSION"] == "1.0.3", "Marketing version differs from the release version")
  check(config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] == BUNDLE, "Bundle mismatch")
  check(config.build_settings["CODE_SIGN_ENTITLEMENTS"] == "#{NAME}/#{NAME}.entitlements", "Entitlement membership mismatch")
  plist = config.build_settings["INFOPLIST_FILE"]
  check(!plist || File.file?(File.join(ROOT, plist)), "Missing Info.plist")
end
project.targets.each do |target|
  synchronized = target.respond_to?(:file_system_synchronized_groups) && target.file_system_synchronized_groups.any?
  if synchronized
    check(target.file_system_synchronized_groups.map(&:path) == [target.name], "Synchronized target folder mismatch")
    check(Dir.glob(File.join(ROOT, target.name, "**/*.swift")).any?, "Missing synchronized sources")
    if target == app
      group = target.file_system_synchronized_groups.first
      excluded = group.exceptions.flat_map(&:membership_exceptions)
      check(excluded.include?("Info.plist"), "Info.plist must not be copied as a resource")
      check(File.directory?(File.join(ROOT, NAME, "Assets.xcassets")), "Missing synchronized asset catalog")
    end
  else
    actual = target.source_build_phase.files_references.map { |ref| ref.real_path.to_s }.sort
    expected = Dir.glob(File.join(ROOT, target.name, "**/*.swift")).sort
    check(actual == expected, "Source membership mismatch: #{target.name}")
    resource_paths = target.resources_build_phase.files_references.flat_map do |ref|
      ref.isa == "PBXVariantGroup" ? ref.children.map { |child| child.real_path.to_s } : [ref.real_path.to_s]
    end
    expected_resources = Dir.glob(File.join(ROOT, target.name, "**/*")).select do |path|
      path.end_with?(".xcassets", ".xcstrings", ".storyboard", ".strings", ".mp3")
    end
    check((expected_resources - resource_paths).empty?, "Missing resource membership: #{target.name}")
    target.resources_build_phase.files_references.each do |ref|
      # Firebase configuration is injected only by the trusted release engine.
      next if ref.path == "GoogleService-Info.plist"
      if ref.isa == "PBXVariantGroup"
        ref.children.each { |child| check(File.exist?(child.real_path), "Missing localization") }
      else
        check(File.exist?(ref.real_path), "Missing resource: #{ref.path}")
      end
    end
  end
end
products = app.package_product_dependencies.map(&:product_name)
linked = app.frameworks_build_phase.files.filter_map { |build| build.product_ref&.product_name }
check(products.sort == linked.sort && products.uniq == products, "SPM product registration mismatch")
modules = Dir.glob(File.join(ROOT, NAME, "**/*.swift")).flat_map { |path| File.read(path, encoding: "UTF-8").scan(/^import ([A-Za-z0-9_]+)/).flatten }.uniq
system_modules = %w[Foundation SwiftUI UIKit AVFoundation AVFAudio StoreKit AppTrackingTransparency AdSupport Firebase NetworkExtension LinkPresentation CoreLocation Network SystemConfiguration UniformTypeIdentifiers]
check((modules - system_modules - products).empty?, "Unlinked imports: #{modules - system_modules - products}")
check(%w[FirebaseCore FirebaseAppCheck FirebaseMessaging QuantumLeap].all? { |name| products.include?(name) }, "Missing Firebase/QuantumLeap products")
pins = JSON.parse(File.read(File.join(project.path, "project.xcworkspace/xcshareddata/swiftpm/Package.resolved"))).fetch("pins")
project.root_object.package_references.each do |package|
  pin = pins.find { |entry| entry.fetch("location").delete_suffix(".git").downcase == package.repositoryURL.delete_suffix(".git").downcase }
  check(pin, "Missing direct package pin")
  expected_requirement = if pin.fetch("identity") == "quantumleap"
    check(pin.fetch("state") == { "revision" => "e68cb0aed9394348b54969e018e14d640b4126e2" }, "QuantumLeap must use the observed immutable 0.0.8 revision")
    { "kind" => "revision", "revision" => pin.fetch("state").fetch("revision") }
  else
    { "kind" => "exactVersion", "version" => pin.fetch("state").fetch("version") }
  end
  check(package.requirement == expected_requirement, "Package requirement does not match lock")
end
pins.each { |pin| check(pin.fetch("state").fetch("revision").match?(/\A[0-9a-f]{40}\z/), "Invalid revision") }
scheme_path = File.join(project.path, "xcshareddata/xcschemes/#{NAME}.xcscheme")
scheme = REXML::Document.new(File.read(scheme_path))
test_ids = REXML::XPath.match(scheme, "//TestableReference/BuildableReference").map { |ref| ref.attributes["BlueprintIdentifier"] }
check(test_ids.sort == project.targets.reject { |target| target == app }.map(&:uuid).sort, "Shared scheme testables mismatch")
REXML::XPath.match(scheme, "//BuildableReference").each do |ref|
  check(project.targets.any? { |target| target.uuid == ref.attributes["BlueprintIdentifier"] && target.name == ref.attributes["BlueprintName"] }, "Scheme target identity mismatch")
end
check(REXML::XPath.first(scheme, "//ArchiveAction").attributes["buildConfiguration"] == "Release", "Archive configuration mismatch")
puts "#{NAME}: project identity, source/resource membership, SPM products/pins and shared testables passed (not an Xcode build)"
