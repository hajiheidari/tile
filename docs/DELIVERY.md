# Delivery

## Local review artifacts

`Web` and `Windows` export presets use matching Godot 4.5.1 templates, with single-threaded WebAssembly for the browser build. Browser export therefore does not require cross-origin isolation headers, but still needs WebGL 2 and correct `application/wasm` MIME type. All web output files must retain their matching `index.*` names.

`tools/serve.mjs` is a loopback-only local static server for review. It is not production hosting. `build/` is intentionally ignored by Git and by the Godot importer.

## Existing Espadna convention

Planned URL: `https://tileh.espadna.com`. The game is hosted independently of `espadna-site`, following its documented convention. When release is approved, use a dedicated Cloudflare static Worker or Pages project serving `build/web`; do not overwrite another game's Worker. `wrangler.jsonc` below is preparation only. No deploy command is part of prototype CI.

Before production: confirm DNS/custom domain ownership, actual available Cloudflare secret names and permission scope, MIME/caching behavior, content security policy, mobile browser checks and privacy/landing pages. Never print secret values. GitHub Actions should be the production deployment path once explicitly authorized, matching the studio's documented workflow.

## Android

Independent package: `com.espadna.tileh`. Install OpenJDK 17 and the Android SDK packages required by the pinned Godot version; then configure the Android export preset in Godot and test a development APK on an actual phone/emulator. Generate/use an app-specific signing key through protected CI inputs; do not copy another app's keystore or commit export credentials. See https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html

No Android SDK/device was available in the current environment, and no APK/AAB has been built or tested. Existing Expo/EAS secrets do not by themselves configure a Godot Android build.

## iOS / TestFlight

Independent bundle ID: `com.espadna.tileh`. Godot iOS export requires macOS, Xcode, matching Godot templates, an app-specific Apple identifier/provisioning and an authorized signing identity/team. Prepare an Xcode archive on a macOS runner and validate on a real iPhone before any TestFlight readiness claim. See https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_ios.html

No macOS runner was executed in this milestone, no iOS archive was built, and no App Store Connect app was created or submitted. Before signed delivery, verify available repository secret **names/scopes** and the app's Apple registration. Do not ask the owner to paste credentials into chat.

## Authorization boundary

Local implementation/testing, a dedicated branch, commit/push and CI artifacts were authorized in the brief. Public website production deployment, App Review, App Store release and purchases are not authorized. Prototype artifacts remain review builds. Private/local preview is not a production release.
