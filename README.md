# iOS-Demo

Minimal SwiftUI iOS app. Builds on GitHub Actions `macos-latest` runner (no Mac needed).

- `iOSDemo/` — Swift sources (`iOSDemoApp.swift`, `ContentView.swift`)
- `.github/workflows/build.yml` — `xcodebuild` on `macos-latest`, unsigned Simulator build

Trigger: push to `main` or run the **iOS Build** workflow manually.
