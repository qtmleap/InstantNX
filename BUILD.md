# Native project and CI

The existing InstantNX project and Package.resolved are retained. The shared
`InstantNX` scheme references actual app/unit/UI target IDs and explicit testables.
The project registers its linked SPM products, including the current direct
SwiftUIIntrospect import, and pins direct requirements to existing lock versions.
Team is `5Q94QJ7G98`, minimum iOS 17; existing bundle and app versions are preserved.
No application behavior or Swift sources were changed.

```sh
bundle exec ruby build-support/reconcile-project.rb
bundle exec ruby build-support/project-contract.rb
ruby fastlane/test/run_all.rb
```

`Release Policy` is the only required release check. Secret-free same-repository
PR checks do not resolve private QuantumLeap. Existing TestFlight/Fastlane code
performs trusted resolution/archive/upload. Broken Swift-package CI (there is no
root Package.swift), hosted checks, AI review and package.json version validation
were removed. CommitLint uses a minimal trusted Ruby conventional-header policy.

The project and build-support locks contain the full Xcode 27 resolver result for
QuantumLeap 1.0.1 (revision 4070b87) and its transitive dependencies.
Linux project contracts and Ruby policies do not prove compilation, simulator
tests or an archive. Fix native errors only from compiler output.

Native Xcode 27 dependency resolution and unsigned simulator build passed.
Marketing version 1.0.3 is the next App Store version after 1.0.2.
