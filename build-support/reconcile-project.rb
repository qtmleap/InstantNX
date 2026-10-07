#!/usr/bin/env ruby
require "xcodeproj"
require "json"
ROOT = File.expand_path("..", __dir__)
NAME = "InstantNX"
project = Xcodeproj::Project.open(File.join(ROOT, "#{NAME}.xcodeproj"))
app = project.targets.find { |target| target.name == NAME } or abort "Missing app target"
pins = JSON.parse(File.read(File.join(project.path, "project.xcworkspace/xcshareddata/swiftpm/Package.resolved"))).fetch("pins")
# SwiftUIIntrospect is imported directly by current source files.
unless app.frameworks_build_phase.files.any? { |build| build.product_ref&.product_name == "SwiftUIIntrospect" }
  pin = pins.find { |entry| entry.fetch("identity") == "swiftui-introspect" } or abort "Missing introspection pin"
  package = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
  package.repositoryURL = pin.fetch("location")
  product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  product.package = package
  product.product_name = "SwiftUIIntrospect"
  build = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build.product_ref = product
  app.frameworks_build_phase.files << build
end
# Repair package registration using the actual existing product references.
products = app.frameworks_build_phase.files.filter_map(&:product_ref).uniq { |product| product.product_name }
app.frameworks_build_phase.files.group_by { |build| build.product_ref&.product_name }.each do |name, builds|
  builds.drop(1).each(&:remove_from_project) if name
end
app.package_product_dependencies.clear
products.each { |product| app.package_product_dependencies << product }
products.map(&:package).uniq.each do |package|
  project.root_object.package_references << package unless project.root_object.package_references.include?(package)
  pin = pins.find { |entry| entry.fetch("location").delete_suffix(".git").downcase == package.repositoryURL.delete_suffix(".git").downcase } or abort "Missing pin: #{package.repositoryURL}"
  # Pin the published 0.0.8 code by revision; its tag has a conflicting cached fingerprint.
  package.requirement = if pin.fetch("identity") == "quantumleap"
    { "kind" => "revision", "revision" => pin.fetch("state").fetch("revision") }
  else
    { "kind" => "exactVersion", "version" => pin.fetch("state").fetch("version") }
  end
end
(project.build_configurations + project.targets.flat_map(&:build_configurations)).each do |config|
  config.build_settings["DEVELOPMENT_TEAM"] = "5Q94QJ7G98"
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "16.0"
end
app.build_configurations.each { |config| config.build_settings["MARKETING_VERSION"] = "1.0.3" }
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.set_launch_target(app)
project.targets.reject { |target| target == app }.each { |target| scheme.add_test_target(target) }
scheme.save_as(project.path, NAME, true)
puts "Reconciled #{NAME} package registration and shared testable scheme"
