fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios code_signing

```sh
[bundle exec] fastlane ios code_signing
```

Syncs certificates and provisioning profiles with match. environment: development, stage, or production (lane option, otherwise APP_BUILD_ENVIRONMENT), mapped to match types development, adhoc, and appstore. readonly defaults to true.

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

Sets the Xcode build number to the latest TestFlight build plus one. Does not commit.

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

Bumps the marketing version in the Xcode project. bump_type: patch (default), minor, or major. Does not commit.

### ios set_current_version_and_build

```sh
[bundle exec] fastlane ios set_current_version_and_build
```

Writes the latest TestFlight version and build number into the Xcode project. Uses 0.1.0 when TestFlight has no version. Does not commit.

### ios commit_current_version_and_build

```sh
[bundle exec] fastlane ios commit_current_version_and_build
```

Writes the latest TestFlight version and build into the Xcode project, then commits that version bump.

### ios tag_release

```sh
[bundle exec] fastlane ios tag_release
```

Creates a local git tag named with the latest TestFlight version. Uses 0.1.0 when TestFlight has no version. Optional commit pins the tag to that commit. Does not push.

### ios test

```sh
[bundle exec] fastlane ios test
```

Runs the QuickPersonalFinanceTests scheme.

### ios build

```sh
[bundle exec] fastlane ios build
```

Builds an ipa. Configuration and export method come from APP_BUILD_ENVIRONMENT: development (Debug, development), stage (Release, ad-hoc), or production (Release, app-store). Defaults to Release and app-store.

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Captures App Store screenshots with snapshot.

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Uploads an ipa to TestFlight.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
