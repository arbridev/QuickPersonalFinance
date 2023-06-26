#  Quick Personal Finance

This app was designed for individuals to quickly calculate their financial projections based on their incomes and expenses.

Check out the app on the **[App Store](https://apps.apple.com/app/quickpersonalfinance/id6448765356)**.

## Tooling

- Xcode 14.2

### Frameworks

- SwiftUI

### Dependencies

#### Cocoapods

- [SwiftLint](https://github.com/realm/SwiftLint)
- [Firebase](https://github.com/firebase/firebase-ios-sdk)
    - [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics/)
    - [Firebase Performance](https://firebase.google.com/docs/perf-mon)

#### Building

To build, this project requires to have a `GoogleService-Info.plist` file located at `/QuickPersonalFinance`.

Swift Package Manager was replaced by Cocoapods since it duplicated some Firebase files which rendered the project impossible to build for unit tests, crashing with the error: [[FBLPromise HTTPBody]: unrecognized selector sent to instance](https://github.com/firebase/firebase-ios-sdk/issues/8005).

Cocoapods requires to run `pod install` if you need to install a new dependency, in any other case the pod sources will be available in the repository.

### Code formatting and linting

Linting rules are set in `.swiftlint.yml`; they will be checked on every build by _SwiftLintPlugin_. Optionally you can run a [pre-commit](https://pre-commit.com/) hook if _pre-commit_ and [SwiftLint](https://github.com/realm/SwiftLint) are installed in your system.

There is a separate file for auto-correct rules `.swiftlint.autocorrect.yml`; you can run it using `swiftlint --config ".swiftlint.autocorrect.yml" --fix` if you have [SwiftLint](https://github.com/realm/SwiftLint) installed in your system.

## License

Quick Personal Finance is released under the MIT license. See [LICENSE](https://github.com/arbridev/QuickPersonalFinance/blob/main/LICENSE) for details.
