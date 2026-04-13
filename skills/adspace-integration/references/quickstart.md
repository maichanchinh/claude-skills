# Quick Start

Use this path when the user wants the fastest correct integration of the library into an Android app.

## Baseline

- Dependency: `implementation("io.github.maichanchinh:adspace-admob:2.0.+")`
- Package imports: `com.admob.adspace.*`
- Min SDK: 26
- Java/Kotlin target: 21

## Manifest

Add AdMob App ID inside `<application>`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY" />
```

## Application Init

Initialize once from `Application.onCreate()`:

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        AdSpaceSDK.initialize(
            this,
            AdSpaceSDKConfig(
                debug = BuildConfig.DEBUG,
                testDevices = emptyList(),
                minInterval = 30L,
                appId = "ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"
            )
        )
    }
}
```

Important:

- Pass the `Application` instance, not an `Activity`.
- `minInterval` here is seconds, not milliseconds.

## Local Config

Create `app/src/main/assets/ad_config.json`:

```json
{
  "global": {
    "enable": true,
    "cmpAuto": true,
    "minInterval": 30000
  },
  "spaces": [
    {
      "space": "ADMOB_Banner_General",
      "adsType": "banner",
      "ids": ["ca-app-pub-3940256099942544/6300978111"],
      "enable": true,
      "minInterval": 30000
    },
    {
      "space": "ADMOB_Interstitial_General",
      "adsType": "interstitial",
      "ids": ["ca-app-pub-3940256099942544/1033173712"],
      "enable": true,
      "minInterval": 30000
    }
  ]
}
```

Notes:

- The file name is `ad_config.json`.
- Use camelCase JSON fields that map to Moshi data classes: `cmpAuto`, `minInterval`, `adChoicesPosition`.
- `adsType` must match the exact supported values.

## First Placement

For a banner:

```kotlin
SpaceBanner.showInlineAdaptive(
    space = "ADMOB_Banner_General",
    viewGroup = bannerContainer,
    forceRefresh = true,
    center = true,
    callback = object : BannerCallback {
        override fun onLoaded(adView: AdView, space: String) = Unit
        override fun onFailed(space: String, error: BannerError) = Unit
    }
)
```

For an interstitial:

```kotlin
SpaceInterstitial.preload(
    space = "ADMOB_Interstitial_General",
    callback = object : InterstitialCallback() {}
)

SpaceInterstitial.show(
    space = "ADMOB_Interstitial_General",
    activity = this,
    callback = object : InterstitialCallback() {},
    nextAction = {
        continueFlow()
    }
)
```

## Verify

- App launches without init crash.
- `ad_config.json` is packaged in app assets.
- CMP appears on first resume when enabled and required.
- Test ad units load successfully.
- `nextAction` still runs when interstitial fails or dismisses.
