# Ad Formats

Use this file only for the placement type being integrated.

## Banner

Use `SpaceBanner`.

Available entry points:

- `show(space, viewGroup, adSize, forceRefresh, center, callback)`
- `showInlineAdaptive(space, viewGroup, forceRefresh, center, callback)`
- `showAnchoredAdaptive(space, viewGroup, position, forceRefresh, center, callback)`
- `showCollapsible(space, viewGroup, position, forceRefresh, center, callback)`
- `clearCache(space?)`

Good defaults:

- Use inline adaptive for content surfaces.
- Use anchored adaptive for fixed footer/header placements.
- Use collapsible only when the UX explicitly supports expandable banner behavior.

## Native

Use `SpaceNativeAd`.

### XML path

The app inflates a `NativeAdView` and passes it to the SDK:

```kotlin
SpaceNativeAd.display(
    space = "ADMOB_Native_Home",
    nativeAdView = binding.nativeAdView,
    callback = object : NativeAdCallback {
        override fun onLoaded(nativeAdView: NativeAdView, nativeAd: NativeAd, space: String) = Unit
        override fun onFailed(space: String, error: NativeAdError) = Unit
    }
)
```

Preload when the screen reuses native ads heavily:

```kotlin
SpaceNativeAd.preload(
    space = "ADMOB_Native_Home",
    callback = object : NativeAdPreloadCallback {
        override fun onPreloadSuccess(space: String, count: Int) = Unit
        override fun onPreloadFailed(space: String, error: NativeAdError) = Unit
    }
)
```

### Compose path

Use `rememberNativeAdState` off the `SpaceNativeAd` singleton:

```kotlin
val adState = SpaceNativeAd.rememberNativeAdState("ADMOB_Native_Home")
if (adState.nativeAd != null) {
    NativeAdMedium(nativeAd = adState.nativeAd)
}
```

Use the provided compose wrappers under `com.admob.adspace.nativead.compose`.

## Interstitial

Use `SpaceInterstitial`.

Pattern:

1. `preload(...)` before the conversion point.
2. `show(...)` with a required `nextAction`.
3. Keep business flow in `nextAction`, not after `show(...)`.

```kotlin
SpaceInterstitial.show(
    space = "ADMOB_Interstitial_General",
    activity = this,
    callback = object : InterstitialCallback() {},
    nextAction = {
        navigateNext()
    }
)
```

Use `isLoaded(space)` or `isReady(space)` only when the host app needs a decision point; otherwise the SDK can load on demand.

## Rewarded

Use `SpaceRewarded`.

`show(...)` requires explicit success and failure continuations:

```kotlin
SpaceRewarded.show(
    space = "ADMOB_Rewarded_General",
    activity = this,
    callback = object : RewardedCallback {},
    onUserEarnedReward = {
        grantReward()
    },
    onFailureUserNotEarn = {
        continueWithoutReward()
    }
)
```

Important behavior:

- If the SDK or space is disabled, the implementation may grant reward immediately.
- Keep reward side effects only in `onUserEarnedReward`.

## Rewarded Interstitial

Use `SpaceRewardedInterstitial`.

The flow mirrors rewarded:

```kotlin
SpaceRewardedInterstitial.show(
    space = "ADMOB_Rewarded_Interstitial_General",
    activity = this,
    callback = object : RewardedInterstitialCallback {},
    onUserEarnedReward = {
        grantReward()
    },
    onFailureUserNotEarn = {
        continueWithoutReward()
    }
)
```

## Open App

There are two distinct open-app flows:

- Foreground/resume: `SpaceOpenResume`
- Splash/startup: `SpaceOpenSplash`

Do not substitute one for the other. The lifecycle contract differs.
