---
name: adspace-integration
description: Integrate the AdSpace AdMob SDK into Android apps with the repo-accurate APIs and config contract. Use when Codex needs to add or fix `io.github.maichanchinh:adspace-admob`, wire `ad_config.json`, initialize `AdSpaceSDK` in `Application`, configure CMP/UMP privacy flows or Firebase Remote Config, implement banner/native/interstitial/rewarded/rewarded interstitial/open-app placements, handle resume or splash ads, or troubleshoot consent, privacy options, and ad gating issues.
---

# AdSpace Integration

Integrate this library by following the real public API in this repo, not generic AdMob patterns and not stale examples.

Prefer the smallest reference file that matches the task. Do not load every reference by default.

## Start Here

1. Confirm the target app can satisfy the baseline:
   - Android minSdk 26+
   - Kotlin/Java 21 toolchain
   - AdMob App ID available for manifest + `AdSpaceSDKConfig.appId`
   - Local asset file named `ad_config.json`
2. Add the dependency and initialize `AdSpaceSDK` from `Application`, not from an `Activity`.
3. Define spaces in local config first. Treat `adsType` as immutable and local-only.
4. Choose the ad flow and load only the relevant reference:
   - Quick setup or first integration: `references/quickstart.md`
   - Banner, native, interstitial, rewarded, rewarded interstitial, open app: `references/formats.md`
   - CMP and Remote Config: `references/consent-config.md`
   - Resume and splash flows: `references/resume-splash.md`
   - Failures or mismatched APIs: `references/troubleshooting.md`
5. Validate the app-side code against demo usage in `app/src/main/java/com/demo/ads/adspace/` when you need a concrete pattern.

## Non-Negotiable Rules

- Use package imports from `com.admob.adspace.*`.
- Use dependency `io.github.maichanchinh:adspace-admob:2.0.+` unless the user pins a version.
- Name the local asset `ad_config.json`. The SDK reads that exact filename.
- Keep `adsType` local-only. Remote Config must not change placement type or core flow.
- Use only these `adsType` values: `banner`, `native`, `interstitial`, `reward`, `reward_inter`, `open_app`.
- Remember the interval unit split:
  - `AdSpaceSDKConfig.minInterval` is in seconds.
  - `ad_config.json` and Remote Config `min_interval` values are in milliseconds.
- Respect the library gates before showing ads:
  - premium user block
  - global kill switch
  - per-space enable flag
  - min interval
  - CMP consent gate
- Treat resume mode as single-active-mode. `AdSpaceSDK` can only hold one resume mode at a time.
- Preserve `nextAction` continuation semantics for splash or interstitial flows. Do not drop the continuation.

## Real API Guardrails

- Banner API is `SpaceBanner`, with `show`, `showInlineAdaptive`, `showAnchoredAdaptive`, and `showCollapsible`.
- Native API is `SpaceNativeAd`, not `SpaceNative`.
- XML native flow uses `SpaceNativeAd.display(...)` with a `NativeAdView` supplied by the app.
- Compose native flow uses `SpaceNativeAd.rememberNativeAdState(...)` and the compose wrappers under `nativead/compose/`.
- Interstitial `show(...)` requires `nextAction`.
- Rewarded and rewarded interstitial `show(...)` require reward and failure continuations.
- Resume ads use `SpaceOpenResume` or `SpaceInterstitialResume`.
- Splash ads use `SpaceOpenSplash` or `SpaceInterstitialSplash`.
- Global skip for the next resume ad is `AdSpaceSDK.skipNextShow()`.
- Manual CMP trigger is `AdSpaceSDK.requestConsent(activity)`.
- CMP completion hook is `AdSpaceSDK.setConsentFlowCompletedCallback { canRequestAds -> ... }`.
- CMP uses `requestConsentInfoUpdate()` on each app launch before the SDK trusts consent state.
- CMP form flow uses `UserMessagingPlatform.loadAndShowConsentFormIfRequired(...)`, not `loadConsentForm()+show()`.
- Auto CMP runs on the first resumed activity when `ads.global.cmp_auto=true`.
- Auto and manual CMP triggers are deduped inside the SDK; do not call `requestConsent(activity)` repeatedly to force refresh.
- Treat `canRequestAds()` as unreliable until the current launch has completed the consent info update.
- If consent callback returns `false`, do not initialize, preload, or request ads.

## Working Style

- Prefer integrating into the host app first. Change the library only when the user explicitly wants SDK behavior changed.
- When updating library code in this repo, preserve the architecture:
  - Facade: `AdSpaceSDK`
  - Core/config/CMP/event bus managers
  - Ad-type public singletons such as `SpaceBanner`, `SpaceInterstitial`, `SpaceOpenResume`
- Reuse the demo app patterns instead of inventing new surface APIs.
- If you see older docs or examples using `ads_config.json`, `SpaceNative`, or callback signatures that do not match the source, correct them to the repo API before proceeding.

## CMP Notes

- Set `AdSpaceSDK.setConsentFlowCompletedCallback(...)` before a manual consent trigger when the host app needs to preload ads after consent.
- Clear the callback with `AdSpaceSDK.setConsentFlowCompletedCallback(null)` when the host component no longer needs the result.
- Do not read or persist `IABTCF_*` strings directly. Let UMP own consent state.
- Do not infer consent from a previous session without a fresh launch-time update.

## Deliverables

- For app integration tasks, leave the host app with:
  - dependency added
  - manifest meta-data added
  - `Application` initialization wired
  - `ad_config.json` created or updated
  - chosen ad placements integrated with the correct callbacks
  - cleanup/cache calls where needed
- For troubleshooting tasks, explain which gate failed:
  - SDK init
  - config lookup
  - global or space disable
  - consent not ready
  - ad not loaded or not ready
  - resume registration missing

## Reference Map

- `references/quickstart.md`: fastest correct setup
- `references/formats.md`: per-format integration patterns
- `references/consent-config.md`: config schema, CMP, Remote Config
- `references/resume-splash.md`: app foreground and launch ads
- `references/troubleshooting.md`: common integration mistakes
