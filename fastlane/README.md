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

Generates code signing items (certificates and provisioning profiles)

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

Increments the build number

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

Increments the version number (bump_type: patch, minor or major)

### ios set_current_version_and_build

```sh
[bundle exec] fastlane ios set_current_version_and_build
```

Sets current version and build

### ios commit_current_version_and_build

```sh
[bundle exec] fastlane ios commit_current_version_and_build
```

Commit current version and build

### ios tag_release

```sh
[bundle exec] fastlane ios tag_release
```

Tag release

### ios tests

```sh
[bundle exec] fastlane ios tests
```



### ios build

```sh
[bundle exec] fastlane ios build
```

Generates an ipa

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Deliver the app to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
