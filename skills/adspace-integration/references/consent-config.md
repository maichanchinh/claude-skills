# Consent And Config

Use this file when the task touches CMP, privacy options, local config, or Firebase Remote Config.

## Local Config Contract

Root model:

```json
{
  "global": {
    "enable": true,
    "cmpAuto": true,
    "minInterval": 30000
  },
  "spaces": []
}
```

Per-space model:

```json
{
  "space": "ADMOB_Native_Home",
  "adsType": "native",
  "ids": ["id-1", "id-2"],
  "enable": true,
  "minInterval": 30000,
  "mute": true,
  "adChoicesPosition": "top_right"
}
```

Supported `adsType` values:

- `banner`
- `native`
- `interstitial`
- `reward`
- `reward_inter`
- `open_app`

## Remote Config Rules

Remote Config supplements local config. It does not redefine the placement model.

Allowed global keys:

- `ads.global.enable`
- `ads.global.cmp_auto`
- `ads.global.min_interval`

Allowed per-space keys:

- `ads.{space}.enable`
- `ads.{space}.min_interval`
- `ads.{space}.ids`

Notes:

- The SDK stores remote IDs as pipe-separated values, then splits them into a waterfall list.
- Older docs may mention `admob_id`; source code uses `ids`.
- Do not attempt to change `adsType` remotely.

## CMP

The SDK auto-initializes the CMP manager and can auto-show consent on the first resumed activity when `ads.global.cmp_auto=true`.

Current flow in source:

1. `CMPManager.requestConsent(activity)` always calls `requestConsentInfoUpdate(...)` for the current app launch.
2. If `consentInformation.canRequestAds()` is already `true` after the update, the flow completes without showing a form.
3. Otherwise the SDK calls `UserMessagingPlatform.loadAndShowConsentFormIfRequired(...)`.
4. `AdSpaceSDK` dedupes overlapping auto and manual consent triggers and invokes the public callback once per completed flow.

Use these entry points:

- `AdSpaceSDK.setConsentFlowCompletedCallback { canRequestAds -> ... }`
- `AdSpaceSDK.requestConsent(activity)`
- `AdSpaceSDK.getCMPManager().showPrivacyOptionsForm(activity)`
- `AdSpaceSDK.getCMPManager().isPrivacyOptionsRequired()`

Typical manual consent flow:

```kotlin
AdSpaceSDK.setConsentFlowCompletedCallback { canRequestAds ->
    if (canRequestAds) {
        preloadAds()
    }
}

AdSpaceSDK.requestConsent(activity)
```

Expected behavior:

- First launch in a consent-required region can take longer because it includes network + form presentation.
- Later launches still refresh consent info, but usually skip the form when prior consent remains valid.
- `canRequestAds()` should only be trusted after the current launch has run the consent info update path.

Remember to clear the callback when the host component no longer needs it:

```kotlin
AdSpaceSDK.setConsentFlowCompletedCallback(null)
```

Do:

- Set the callback before a manual CMP trigger if the app needs to preload or request ads after consent.
- Branch on `canRequestAds` from the callback before starting ad work.
- Use `showPrivacyOptionsForm(activity)` from a visible privacy entry point when required.

Don't:

- Read `IABTCF_*` keys or infer consent from cached local strings.
- Assume `canRequestAds()` is `true` before `requestConsentInfoUpdate(...)` has run in the current launch.
- Call `requestConsent(activity)` repeatedly to force refresh; the SDK already dedupes overlapping consent flows.

## Gating Order

When ads do not show, inspect gates in this order:

1. SDK initialized
2. global enable
3. ad type enabled
4. space exists
5. space enabled
6. CMP allows requests
7. ad is loaded or ready

## Useful SDK Toggles

- `AdSpaceSDK.setAdTypeEnabled(AdsType.BANNER, false)`
- `AdSpaceSDK.isAdTypeEnabled(AdsType.BANNER)`
- `AdSpaceSDK.isAdMobReady()`
- `AdSpaceSDK.getCurrentActivity()`
