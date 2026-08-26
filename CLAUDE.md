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

Currently `KoffeerTests` and `KoffeerUITests` are unmodified Xcode boilerplate —
there is no real coverage yet. Building it up is an active goal, not an
afterthought.

- Swift Testing (`@Test`, `#expect`) for new tests, not XCTest.
- Every ViewModel gets tests. Use in-memory fake repositories conforming to the
  protocols — that is what the protocol layer exists for.
- Views do not need tests.
- When adding behaviour, write the test first.

## Known issues

Real problems, already identified. Don't rediscover them, and don't fix them
as a side effect of unrelated work — each is its own change.

1. **`TextRecognition.swift` is dead code.** It duplicates
   `VisionTextRecognitionService` in completion-handler style, left over from the
   refactor to protocols. Should be deleted.
2. **`RecipeView` hardcodes exactly three brew steps** with remote image URLs. It
   does not generalise to `Item.steps` of arbitrary length, and it breaks if the
   third-party CDN goes away. Should be driven by the model, with local assets.
3. **`update(_:)` on both SwiftData repositories ignores its parameter** and just
   saves the context. It happens to work because SwiftData models are reference
   types already tracked by the context, but the signature is misleading.
4. **No test coverage** beyond scaffolding.

## Planned work

- Test coverage for all four ViewModels
- Fix the three issues above
- The `RecipeView` timer uses `Timer.scheduledTimer` on a 10ms tick — a good
  candidate for `AsyncStream` or a `Task` with `Task.sleep`, and a better fit
  for the strict-concurrency target

## Working style

- Small commits, one logical change each. Commit often.
- Do not refactor code you were not asked to touch. Mention it instead.
- Do not add comments explaining *what* the code does. Explain *why*, and only
  when it is not obvious.
- If a change spans many files, outline the plan before writing code.
- Ask before adding a dependency, changing the architecture, or altering the
  SwiftData schema.
