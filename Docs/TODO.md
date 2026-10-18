# Koffeer TODOs

Reviewed 2026-10-18 against the current source. Each task should be a separate,
focused change. Write Swift Testing tests before adding behavior; use protocol
fakes for ViewModels and integration tests for persistence and files.

## 1. Reliable editing and persistence

- [ ] Make `BlendViewModel.saveChanges()` report success or failure. Keep the
  editor and draft open on failure; dismiss only after a successful save.
- [ ] Define how failed saves restore already-mutated SwiftData model fields,
  so a later save cannot accidentally persist a failed edit.
- [ ] Add visible loading, error, and retry states to list and editor ViewModels.
  Distinguish a failed fetch from an empty list and preserve loaded content on
  refresh failure. Update the existing fetch-failure test with the new behavior.
- [ ] Move blend assignment from `RecipesView` into its ViewModel and save it
  explicitly through the repository; test failure and relaunch/readback.
- [ ] Clarify repository `update(_:)` semantics: both implementations currently
  save the context without using the supplied parameter.
- [ ] Define blend deletion behavior for linked brews before changing the
  relationship or delete rules; verify it with an in-memory SwiftData container.

## 2. Brew steps and timer

- [ ] Render arbitrary brew steps instead of three hardcoded sections. Replace
  remote illustrations with local assets and represent the active step directly.
- [ ] Decide whether step boundaries pause or continue, and whether background
  time counts. Preserve the current behavior until those decisions are made.
- [ ] Replace the 10 ms timer with a cancellable task and elapsed time derived
  from a clock. Inject time for deterministic tests rather than waiting in tests.
- [ ] Test pause/resume/reset, final-step completion, empty steps, and screen
  exit/re-entry. Audit the current start/resume step-selection logic.
- [ ] Correct timer fractional-second formatting: the display currently uses
  milliseconds modulo 100 instead of centiseconds.

## 3. Observation, concurrency, and tests

- [ ] Migrate all four ViewModels from `ObservableObject` / `@Published` to
  `@Observable`, with view-owned `@State` and bindings where needed.
- [ ] Resolve actor-isolation diagnostics and remove target-level Swift 5
  overrides. Verify Swift 6 in Debug and Release without weakening checks.
- [ ] Add meaningful tests for `BlendViewModel`, `RecipesViewModel`, and
  `RecipeViewModel`; extend the four existing blends-list tests for failures.
- [ ] Keep repository/service construction at the root and remove dependency
  forwarding from feature Views when addressing navigation separately.

## 4. Photos and OCR

- [ ] Give imports and OCR explicit task ownership, cancellation, progress, and
  stale-result protection. A canceled older request must not publish its result.
- [ ] Downsample imports, normalize orientation, validate image data, and produce
  bounded display images and list thumbnails.
- [ ] Return distinct OCR success, no-text, and failure outcomes. Audit the
  continuation bridge for exactly-once resumption and cancellation handling.
- [ ] Present OCR as a reviewable draft; never overwrite newer user edits.
- [ ] Implement the chosen explicit-file storage approach with safe replacement,
  deletion, orphan recovery, and a rerunnable migration from `imageData`.

Use [ImageProcessingRoadmap.md](ImageProcessingRoadmap.md) for detailed image
acceptance criteria. Camera capture, crop, zoom, and comparison come afterward.
Approve schema and migration design before implementation.

## 5. Product flow and polish

- [ ] Separate blend editing from blend selection; make row actions explicit.
- [ ] Replace placeholder brew creation with method, blend, and step selection.
- [ ] Decide whether recipes are reusable templates or individual brew sessions
  before proposing new schema fields such as dose, water, grind, or temperature.
- [ ] Add stable list sorting, useful empty states, search, and working previews.
- [ ] Audit VoiceOver, rating/photo controls, Dynamic Type, and light/dark mode.
- [ ] Review the initial tab selection: `selectedTab` is 0, but tags are 1 and 2.
- [ ] Handle model-container startup failures deliberately and correct the
  current error message interpolation. Never reset stored data as recovery.
- [ ] Add CI builds and unit tests once the Swift 6 migration is complete.
- [ ] Refresh `AGENTS.md`: dead OCR cleanup is complete, and four real unit tests
  already exist; observation and Swift 6 target migration are still pending.
