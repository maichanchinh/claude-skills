# Troubleshooting

Use this file when the integration compiles but ads do not show, callbacks do not fire, or the user has copied an outdated example.

## Common Mismatches

- Wrong asset name: use `ad_config.json`, not `ads_config.json`.
- Wrong native class: use `SpaceNativeAd`, not `SpaceNative`.
- Wrong config field names: source models use `cmpAuto`, `minInterval`, `adChoicesPosition`.
- Wrong remote key for IDs: source code reads `ads.{space}.ids`.
- Wrong callback shape: `SpaceInterstitial.show(...)` requires `nextAction`.
- Wrong context for init: `AdSpaceSDK.initialize(...)` requires `Application`.

## Debug Checklist

1. Verify init:
   - `AdSpaceSDK.initialize(application, config)` ran exactly once.
   - The passed context is an `Application`.
2. Verify config:
   - `ad_config.json` exists in app assets.
   - The requested `space` name matches config exactly.
   - `adsType` is compatible with the API being called.
3. Verify gating:
   - premium path is not blocking
   - global enable is true
   - space enable is true
   - CMP allows ad requests
4. Verify readiness:
   - for preloaded flows, inspect `isLoaded(...)` or `isReady(...)`
   - for resume flows, ensure `registerAndLoad(...)` happened
5. Verify lifecycle:
   - splash activity may need `setIgnoreAdResume(...)`
   - only one resume mode can be active

## Troubleshooting by Symptom

### Interstitial never continues app flow

Cause:

- `nextAction` omitted, misplaced, or moved outside the callback-driven API.

Fix:

- Keep continuation in `nextAction`.

### Resume ads never appear

Cause:

- Resume mode was never registered.
- Another resume mode replaced the intended one.
- Activity is on the ignore list.

Fix:

- Register with `SpaceOpenResume.registerAndLoad(...)` or `SpaceInterstitialResume.registerAndLoad(...)`.
- Check whether another part of the app called `AdSpaceSDK.setResumeMode(...)`.

### Native ad view stays empty

Cause:

- The app passed the wrong view type.
- The space is disabled or not found.
- AdMob readiness or CMP gate has not completed yet.

Fix:

- For XML, pass a real `NativeAdView`.
- For Compose, use `rememberNativeAdState(...)`.

### CMP never appears

Cause:

- `cmpAuto` disabled
- the user already has consent
- the integration is using a non-activity context for manual request

Fix:

- Check `AdSpaceSDK.setConsentFlowCompletedCallback(...)`.
- Use `AdSpaceSDK.requestConsent(activity)` for manual flow.
