# NoteNook (macOS-only)

NoteNook is an exclusively macOS application targeting macOS 16+.

## Platform Support
- macOS only. Building or running on Windows, Linux, or other platforms is unsupported.
- Non-macOS builds fail with a clear compile-time error: "NoteNook is a macOS-exclusive application. Build aborted: non-macOS platform detected."

## Why macOS-only
- Uses AppKit (`NSStatusItem`, `NSMenu`, `NSWindow`) and macOS Security/Keychain APIs.

## Build Requirements
- Xcode 15+ and Swift 6.
- SwiftPM `platforms: [.macOS(.v16)]`.
- Xcode target settings:
  - `SUPPORTED_PLATFORMS = macosx`
  - `MACOSX_DEPLOYMENT_TARGET = 16.0`

## System Requirements & Permissions
- App Sandbox and Hardened Runtime enabled.
- Keychain access via `keychain-access-groups` entitlement.
- If distributing outside Xcode, Gatekeeper quarantine may apply. Remove with `xattr -d com.apple.quarantine "/path/to/NoteNook.app"`.

## Menubar UI
- Agent app (`LSUIElement = true`), status item appears in the macOS menubar.
- Uses SF Symbols or a template icon; falls back to title if needed.

## Failure Behavior
- Attempting to build on non-macOS platforms fails at compile time with a clear message.