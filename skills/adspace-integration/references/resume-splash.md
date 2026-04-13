# Resume And Splash

Use this file when the task is about foreground ads, app-open ads, splash ads, or skip-next-show behavior.

## Resume Modes

`AdSpaceSDK` supports one active resume mode at a time:

- `ResumeMode.NONE`
- `ResumeMode.OPEN_ADS`
- `ResumeMode.INTERSTITIAL`

Setting one mode replaces the previous mode.

## Open Resume

Use `SpaceOpenResume` when the app should show an open-app ad after returning to foreground.

Main API:

- `registerAndLoad(space, callback)`
- `preload(space, forceRefresh, callback)`
- `skipNextShow()`
- `unregister()`
- `isLoaded(space)`
- `isReady(space)`
- `clearCache(space)`

Recommended pattern:

```kotlin
SpaceOpenResume.registerAndLoad(
    space = "ADMOB_Open_Resume_General",
    callback = object : OpenCallback {}
)
```

Use `AdSpaceSDK.setIgnoreAdResume(SomeActivity::class.java)` to exclude screens such as splash or paywall screens.

## Interstitial Resume

Use `SpaceInterstitialResume` when the foreground ad should be interstitial instead of open-app.

Main API:

- `registerAndLoad(space, callback)`
- `skipNextShow()`
- `unregister()`
- `getStatus()`
- `isLoaded(space)`
- `isReady(space)`
- `clearCache(space)`

This flow shows a welcome-back dialog before the interstitial.

## Global Skip

Use `AdSpaceSDK.skipNextShow()` when the next foreground ad should be skipped regardless of whether open resume or interstitial resume is active.

## Open Splash

Use `SpaceOpenSplash.show(...)` for launch-time app-open ads with timeout semantics.

```kotlin
SpaceOpenSplash.show(
    space = "ADMOB_Open_Splash_General",
    activity = this,
    timeoutMs = 15_000L,
    callback = object : OpenCallback {},
    nextAction = {
        continueStartup()
    }
)
```

Rules:

- `nextAction` must always continue startup.
- Timeout still triggers `nextAction`.
- `cancel()` aborts the current splash operation.

## Interstitial Splash

Use `SpaceInterstitialSplash.show(...)` for launch-time interstitial ads:

```kotlin
SpaceInterstitialSplash.show(
    space = "ADMOB_Interstitial_Splash",
    activity = this,
    timeoutMs = 15_000L,
    showLoading = false,
    showAdCallback = object : InterstitialCallback() {},
    nextAction = {
        continueStartup()
    }
)
```

Rules:

- Keep startup continuation in `nextAction`.
- Do not block splash indefinitely waiting for ad load.
- Let timeout resolve the flow.
