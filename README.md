# Koffeer

A SwiftUI + SwiftData iOS app for tracking coffee brew recipes and coffee blends.


## Features

- **Recipes** — log brews (V60, Aeropress), track pour steps with an
  auto-advancing stopwatch timer, link each brew to a coffee blend
- **Blends** — manage coffee blends with tasting notes (sweetness, sourness,
  bitterness), photos, and OCR-assisted note entry via Vision

## Stack

- SwiftUI, SwiftData
- Swift 6 language mode in app and test targets, with actor isolation checking
- Swift Testing for unit tests
- No third-party dependencies

## Architecture

MVVM with protocol-based repositories, wired by hand in `RootDIView` — no
singletons, no service locator. ViewModels use `@Observable` on `@MainActor`,
with view-owned `@State` and `@Bindable` access for bindings.

Repository `update(_:)` requires a model owned by that repository's context and
saves all pending changes in the context. Editors restore their model fields
after a failed save and retain the draft for retry. Blends referenced by saved
brews cannot be deleted until those brews are reassigned or deleted.

The brew timer uses an injected monotonic clock and a cancellable refresh task.
It pauses at each step boundary and whenever the brew screen becomes inactive;
resuming requires an explicit tap.

## Current limitations

- Photos are stored as imported `Data` on `CoffeeBlend`, with no explicit file
  lifecycle, downsampling, or thumbnail cache.
- OCR imports recognized text directly into notes; errors and overlapping work
  need explicit handling.
- Twenty-five Swift Testing tests cover all four ViewModels and persistence
  boundaries. UI tests remain Xcode scaffolding.
- Brew instructions remain generic until the recipe catalog is wired up.

## Next work

See [TODOs](Docs/TODO.md) for the prioritized app backlog and completion criteria.

See [the image processing and storage roadmap](Docs/ImageProcessingRoadmap.md)
for the proposed sequence, acceptance criteria, and design decisions.
