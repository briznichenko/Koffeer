# Koffeer

SwiftUI + SwiftData iOS app for tracking coffee brew recipes and coffee blends.

Personal project. It doubles as a practice codebase for modern Swift — so
prefer current APIs over familiar ones, and prefer doing a thing properly over
doing it quickly.

## Commands

```bash
# List available simulators first — do not assume a device name exists
xcrun simctl list devices available

# Build
xcodebuild -scheme Koffeer -destination 'platform=iOS Simulator,name=<device>' build

# Test
xcodebuild -scheme Koffeer -destination 'platform=iOS Simulator,name=<device>' test
```

## Architecture

MVVM with protocol-based repositories, wired by hand at the root. No singletons,
no service locator.

**Models** (`Item.swift`) — both are SwiftData `@Model` classes:
- `CoffeeBlend` — name, tasting notes (sweetness / sourness / bitterness), photo
- `Item` — a single brew: type (`.v60` / `.aeropress`), pour timestamps (`steps`),
  linked `CoffeeBlend`

**Persistence** — `BlendsRepository` / `ItemsRepository` protocols, with
`SwiftDataBlendsRepository` / `SwiftDataItemsRepository` implementations wrapping
`ModelContext`.

**Dependency injection** — `KoffeerApp` builds the `ModelContainer`; `RootDIView`
constructs concrete repositories and services and injects them into `ContentView`
(a two-tab `TabView`: Recipes, Blends).

**Screens** — one View / ViewModel folder pair each:
- `RecipesView` / `RecipesViewModel` — brew list, add/delete, navigation to a
  recipe, sheet to assign a blend
- `RecipeView` / `RecipeViewModel` — brew steps plus a stopwatch timer that
  auto-advances and collapses sections at each step timestamp
- `BlendsView` / `BlendsViewModel` — blend list, add/delete
- `BlendView` / `BlendViewModel` — edit name, details, photo, ratings;
  `PhotosPicker` for images; OCR into the details field

**Services** — `TextRecognitionService` protocol with `VisionTextRecognitionService`
(Apple Vision `VNRecognizeTextRequest`, en/uk, accurate mode).

**Shared views** — `StarRatingView`, `CollapsibleView`.
**Helpers** — `ImageHelper.avatarUIImage(from:)` and a `UIImage(color:size:)`
extension for placeholder generation.

## Conventions

**Layering — this is the rule that matters most:**
- Views never touch repositories, services or `ModelContext`. Views talk to their
  ViewModel and nothing else.
- ViewModels depend on repository and service *protocols*, never concrete types.
- New service? Define the protocol first, then the implementation — follow the
  `TextRecognitionService` pattern.
- New dependency gets constructed in `RootDIView` and injected down. Never reach
  for a shared instance.

**Swift:**
- Swift 6 language mode with strict concurrency checking ON. If it complains,
  fix the actual isolation — do not disable the check or paper over it with
  `@unchecked Sendable`.
- `async`/`await` and structured concurrency. No completion handlers in new code.
- `@Observable` for ViewModels, not `ObservableObject` / `@Published`.
- SwiftUI only. No UIKit unless there is genuinely no SwiftUI equivalent, and
  then say why in a comment.

**Dependencies:**
- SPM only. No CocoaPods.
- No third-party packages without asking first. `URLSession` over Alamofire,
  Apple frameworks over wrappers.

## Testing

`KoffeerTests` has 25 Swift Testing tests covering all four ViewModels and
in-memory SwiftData integration. `KoffeerUITests` remains Xcode boilerplate.

- Swift Testing (`@Test`, `#expect`) for new tests, not XCTest.
- Every ViewModel gets tests. Use in-memory fake repositories conforming to the
  protocols — that is what the protocol layer exists for.
- Views do not need tests.
- When adding behaviour, write the test first.

## Known issues

Real problems, already identified. Don't rediscover them, and don't fix them
as a side effect of unrelated work — each is its own change.

1. Photo imports and OCR need explicit task ownership, cancellation, and
   protection against stale results. OCR currently overwrites notes directly.
2. Photos remain binary data in SwiftData; downsampling, thumbnails, and the
   approved explicit-file storage design still need implementation.
3. Recipe catalog loading and UI wiring are user-owned. Existing brew records
   contain only time boundaries, so step descriptions remain generic.
4. Feature Views still forward dependencies for navigation; address navigation
   ownership as a separate change.

## Completed foundations

- ViewModels use `@Observable`; Views own them with `@State` and access bindings
  with `@Bindable`.
- App and test targets use Swift 6 in Debug and Release.
- Failed saves retain drafts and restore model fields; failed refreshes preserve
  loaded content. Blend assignment saves explicitly through its ViewModel.
- Repository updates validate model-context ownership, then save all pending
  context changes. Linked blends cannot be deleted.
- The timer uses an injected monotonic clock, pauses at step boundaries and when
  its screen is inactive, and resumes only on an explicit tap.

## Planned work

Follow `Docs/TODO.md` and `Docs/ImageProcessingRoadmap.md` for remaining work.
Image-file schema and migration design require approval before implementation.

## Working style

- Small commits, one logical change each. Commit often.
- Do not refactor code you were not asked to touch. Mention it instead.
- Do not add comments explaining *what* the code does. Explain *why*, and only
  when it is not obvious.
- If a change spans many files, outline the plan before writing code.
- Ask before adding a dependency, changing the architecture, or altering the
  SwiftData schema.
