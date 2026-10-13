# Image processing and storage roadmap

Reviewed 2026-10-13. This is a development plan, not implemented functionality.

## Goal

Build a reliable coffee-photo workflow: import, process, save, reopen, replace,
and delete photos; then add capture, editing, and comparison. The user selected
explicit image files plus database metadata as the storage approach.

The current [inVerita role](https://jobs.dou.ua/companies/inveritasoft/vacancies/342249/)
names photo capture, image handling/storage, backend synchronization, and privacy,
with thumbnails, cropping, zoom, and comparison as additional experience.
Koffeer provides personal-project practice in those mechanisms, not evidence of
production healthcare experience.

## Starting point

- `PhotosPicker` loads image bytes into `BlendViewModel.imageData`.
- `CoffeeBlend.imageData` persists those bytes with SwiftData.
- Lists construct `UIImage` from the stored bytes during rendering.
- Vision OCR returns a string, with empty text also representing failures.
- The editor creates unstructured tasks for import and OCR; older results can
  replace newer state. Done dismisses even when persistence fails.
- The project declares Swift 6, but app and test targets override it with Swift 5.
- The current build reports actor-isolation warnings in the recipe timer's
  `Sendable` callback; enabling Swift 6 will make those errors.
- All four ViewModels use Combine observation; four tests cover the blends list.

## 1. Establish the concurrency and testing foundation

Separate small commits: migrate observation, enable actual Swift 6 checking,
then fix isolation diagnostics. Keep the recipe timer change separate from
the photo work. Do not disable checking or add `@unchecked Sendable`.

Use `@Observable` with view-owned `@State` and bindings where needed. Keep
ViewModels and SwiftData access on `@MainActor`; processing and filesystem work
need deliberate isolation. An `async` signature alone does not move expensive
work off the main actor, particularly with this project's default isolation.

Write Swift Testing tests before new behavior, using fake repository and image
services. First cases: persistence failure keeps the editor open; replacement
imports supersede older results; canceling an import cannot publish its result.

Done when: Debug and Release use Swift 6, relevant unit tests pass, and new
photo work has an explicit ownership and cancellation model.

## 2. Process photo imports without changing persistence yet

Introduce a processing protocol and an Apple-framework implementation, injected
from the root. Pass transferable values such as `Data`, not SwiftData models,
across isolation boundaries. Downsample with Image I/O before full decoding;
handle orientation, validate decodability and dimensions, and create a bounded
display image and a smaller list thumbnail. Choose pixel and byte budgets using
device measurements rather than treating initial limits as established facts.

Show loading and actionable failure states. Tie import work to the selected
photo and editor lifetime. Check cancellation before publishing; a generation
identifier must reject stale results even if underlying work ignores cancellation.

Tests first: invalid bytes, output dimension limits, portrait orientation,
latest-selection wins, and cancellation. Use small local fixtures. Verify
large-photo memory use on a physical device and list scrolling in Instruments.

Done when: an imported image displays correctly, processing is bounded, and
failed or superseded imports preserve the current photo.

## 3. Own the image-file lifecycle

Define an image-store protocol with an actor-backed local implementation. Keep
durable images in Application Support and regenerable thumbnails in Caches.
Store opaque relative identifiers and agreed metadata in SwiftData; resolve
paths within the store. Do not persist absolute sandbox paths.

Proposed first version: one processed master per blend, plus a regenerable
thumbnail. Retaining full-resolution originals adds storage cost and should be
an explicit later decision. Agree on format, metadata, backup/file-protection
policy, and migration before changing `CoffeeBlend`.

File writes and database saves are separate operations:

1. Write the new image under a unique identifier, with an atomic file write.
2. Save the new reference in SwiftData. Keep the old image until this succeeds.
3. On save failure, restore the old in-memory reference and remove the new file;
   failed cleanup remains recoverable.
4. After a successful replacement, remove the old file. On deletion, save the
   database removal first, then clean up the now-unreferenced file.
5. Reconcile orphan files after interruption, excluding active/staged imports.
   A missing thumbnail is regenerated; a missing master produces a recoverable
   error rather than silently deleting the record.

An actor protects its isolated state, not the entire workflow across an `await`.
Other operations can enter while it is suspended. Track active imports and
serialize commits per blend so replacement, deletion, and reconciliation
cannot invalidate each other's files. This is an interview-level reentrancy case.

Migration must preserve existing `imageData` until each new file and reference
is durably saved, be safe to rerun, and report malformed legacy images. Never
reset the user's database as a migration shortcut.

Tests first: reopen/readback, replace, delete, failed write, failed database
save, failed cleanup, missing files, and interrupted/repeated migration. Use a
temporary directory for file-store integration tests and an in-memory SwiftData
container for persistence tests; fake services cover ViewModel orchestration.

Done when: photos survive relaunch, failed replacement preserves the old photo,
and interrupted work neither loses referenced images nor accumulates permanent
orphans. Schema and migration design require approval before implementation.

## 4. Make label scanning useful and reliable

OCR should produce a reviewable draft rather than overwrite notes immediately.
Distinguish no text from failure, prevent stale OCR from overwriting edits, and
show progress/cancellation. Prefer a single async throwing result path; audit
the current continuation bridge for multiple-resume paths and cancellation.

Tests first: recognized text, no text, failure, cancellation, photo replacement
during scanning, and user edits while recognition is running.

Done when: the user can review and apply recognized text without losing notes.

## 5. Capture, crop, and zoom

Reuse the import pipeline for camera output. Choose a system capture interface
for still photos; use AVFoundation only if custom guidance or capture controls
justify its complexity. Any UIKit bridge needs a documented rationale before
implementation. Test permission denial and capture on a physical device.

Add crop/rotate with preview and explicit confirmation, then full-screen zoom.
Define crop coordinates against orientation-normalized pixels. Preserve the
previous saved image until the edited replacement commits successfully.

Done when: camera and library images follow the same validated storage path,
and crop output matches the preview across portrait and landscape images.

## 6. Compare photos; optionally synchronize

Comparison needs multiple retained photos. First agree whether these belong to
a blend or individual brews, then design that schema separately. Add dated
photos and side-by-side comparison with matched scale and zoom; inconsistent
lighting and framing limit visual comparison.

Backend upload is optional after local correctness. It needs an actual API
contract, stable identifiers, retry/idempotency rules, conflict handling, and
deletion semantics. Do not build a pretend backend only to check off REST work.

## Keep separate

Repository `update(_:)` naming, generalized recipe steps/local illustrations,
and remaining list/timer tests deserve their own changes. Avoid adding Combine
solely as interview practice; the image pipeline has a clearer async/await fit.

## References

- [Apple: Image and Graphics Best Practices](https://devstreaming-cdn.apple.com/videos/wwdc/2018/219mybpx95zm9x/219/219_image_and_graphics_best_practices.pdf)
- [Apple: thumbnail orientation transform](https://developer.apple.com/documentation/imageio/kcgimagesourcecreatethumbnailwithtransform)
- [Apple: SwiftData external storage alternative](https://developer.apple.com/documentation/swiftdata/schema/attribute/option/externalstorage)

SwiftData external storage lets the framework manage binary data adjacent to
its model store. It remains a simpler alternative; explicit files were chosen
here to practise lifecycle, failure recovery, and storage boundaries.
