# Koffeer

A SwiftUI + SwiftData iOS app for tracking coffee brew recipes and coffee blends.

Personal project, doubling as a practice codebase for modern Swift — Swift 6
strict concurrency, `@Observable`, and structured concurrency throughout.

## Features

- **Recipes** — log brews (V60, Aeropress), track pour steps with an
  auto-advancing stopwatch timer, link each brew to a coffee blend
- **Blends** — manage coffee blends with tasting notes (sweetness, sourness,
  bitterness), photos, and OCR-assisted note entry via Vision

## Stack

- SwiftUI, SwiftData
- Swift 6 language mode, strict concurrency checking
- Swift Testing for unit tests
- No third-party dependencies

## Architecture

MVVM with protocol-based repositories, wired by hand in `RootDIView` — no
singletons, no service locator. See [CLAUDE.md](CLAUDE.md) for the full
architecture, conventions, and known issues.

## Building

```bash
xcrun simctl list devices available
xcodebuild -scheme Koffeer -destination 'platform=iOS Simulator,name=<device>' build
```

## Testing

```bash
xcodebuild -scheme Koffeer -destination 'platform=iOS Simulator,name=<device>' test
```

Test coverage is a work in progress — `BlendsViewModel` is covered so far,
with the remaining ViewModels next.
