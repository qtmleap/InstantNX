# Native project and CI

The existing InstantNX project and Package.resolved are retained. The shared
`InstantNX` scheme references actual app/unit/UI target IDs and explicit testables.
The project registers its linked SPM products, including the current direct
SwiftUIIntrospect import, and pins direct requirements to existing lock versions.
Team is `5Q94QJ7G98`, minimum iOS 16; existing bundle and app versions are preserved.
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

The existing lock is a baseline, not a newly verified full resolver result.
QuantumLeap 0.0.8 declares public SwiftFormat/SwiftLintPlugins dependencies absent
from that lock. The Codex Mac must run the actual full Xcode resolver and reconcile
all resulting pins before native dependency resolution can be declared verified.
Linux project contracts and Ruby policies do not prove compilation, simulator
tests or an archive. Fix native errors only from compiler output.

Native Xcode 27 dependency resolution and unsigned simulator build passed.
Marketing version 1.0.2 matches the latest TestFlight version.
