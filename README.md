# Koffeer

A SwiftUI + SwiftData iOS app for tracking coffee brew recipes and coffee blends.


## Features

- **Recipes** — log brews (V60, Aeropress), track pour steps with an
  auto-advancing stopwatch timer, link each brew to a coffee blend
- **Blends** — manage coffee blends with tasting notes (sweetness, sourness,
  bitterness), photos, and OCR-assisted note entry via Vision

## Stack

- SwiftUI, SwiftData
- Swift 6 migration in progress: the project specifies Swift 6, but targets
  currently override it with Swift 5 language mode
- Swift Testing for unit tests
- No third-party dependencies

## Architecture

MVVM with protocol-based repositories, wired by hand in `RootDIView` — no
singletons, no service locator.

## Current limitations

- ViewModels still use `ObservableObject` / `@Published`; migration to
  `@Observable` is planned.
- Photos are stored as imported `Data` on `CoffeeBlend`, with no explicit file
  lifecycle, downsampling, or thumbnail cache.
- OCR imports recognized text directly into notes; errors and overlapping work
  need explicit handling.
- Four Swift Testing tests cover `BlendsViewModel`. The other three ViewModels
  have no tests yet; UI tests remain Xcode scaffolding.
- Brew-step rendering and the timer need separate follow-up changes.

## Next work

See [TODOs](Docs/TODO.md) for the prioritized app backlog and completion criteria.

See [the image processing and storage roadmap](Docs/ImageProcessingRoadmap.md)
for the proposed sequence, acceptance criteria, and design decisions.
