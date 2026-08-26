# Koffeer

A SwiftUI + SwiftData iOS app for tracking coffee brew recipes and coffee blends.


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
singletons, no service locator.
