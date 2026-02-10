---
name: admob-integration
description: AdSpaceSDK (AdMob Next-Gen wrapper) integration for Android. Covers all ad types (Banner, Native, Interstitial, Rewarded, Rewarded Interstitial, Open App), CMP consent (UMP/GDPR), Firebase Remote Config, resume ads. Both View API (XML/Kotlin) and Jetpack Compose. Min SDK 26, Java 21.
---

# AdSpaceSDK Integration

Complete integration guide for AdSpaceSDK - an Ad Orchestration Layer wrapping Google AdMob Next-Gen SDK with CMP integration.

## Package Information

**CRITICAL**: Always use the correct package name to avoid confusion:

- **Maven Dependency**: `io.github.maichanchinh:adspace-admob:2.0.+`
- **Package Name**: `com.admob.adspace`
- **Min SDK**: Android 26 (API 26+)
- **Java/Kotlin**: Java 21, JVM target 21

All code examples use imports from `com.admob.adspace.*` package.

## Quick Reference

### Common Imports

```kotlin
// Core SDK
import com.admob.adspace.AdSpaceSDK
import com.admob.adspace.AdSpaceSDKConfig

// Banner Ads
import com.admob.adspace.banner.SpaceBanner
import com.admob.adspace.banner.BannerCallback
import com.admob.adspace.banner.BannerError
import com.admob.adspace.banner.AdRevenue
import com.google.android.libraries.ads.mobile.sdk.banner.AdView

// Native Ads
import com.admob.adspace.native.SpaceNative
import com.admob.adspace.native.NativeCallback
import com.admob.adspace.native.NativeError
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView

// Interstitial Ads
import com.admob.adspace.interstitial.SpaceInterstitial
import com.admob.adspace.interstitial.InterstitialCallback
import com.admob.adspace.interstitial.InterstitialError

// Rewarded Ads
import com.admob.adspace.rewarded.SpaceRewarded
import com.admob.adspace.rewarded.RewardedCallback
import com.admob.adspace.rewarded.RewardedError

// Rewarded Interstitial Ads
import com.admob.adspace.rewardedinterstitial.SpaceRewardedInterstitial
import com.admob.adspace.rewardedinterstitial.RewardedInterstitialCallback
import com.admob.adspace.rewardedinterstitial.RewardedInterstitialError

// Open App Ads
import com.admob.adspace.open.SpaceOpenApp
import com.admob.adspace.open.OpenAppCallback
import com.admob.adspace.open.OpenAppError
```

## Initial Setup

### 1. Add Dependency

Add to app module's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("io.github.maichanchinh:adspace-admob:2.0.+")
}
```

### 2. Configure AndroidManifest.xml

Add AdMob App ID:

```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

Replace with your actual AdMob App ID from AdMob console.

### 3. Initialize SDK

In `Application.onCreate()`:

```kotlin
import android.app.Application
import com.admob.adspace.AdSpaceSDK
import com.admob.adspace.AdSpaceSDKConfig

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        val config = AdSpaceSDKConfig(
            debug = BuildConfig.DEBUG,
            testDevices = emptyList(), // Add test device IDs for testing
            minInterval = 30L, // Minimum interval between ads (seconds)
            appId = "ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"
        )

        AdSpaceSDK.initialize(this, config)
    }
}
```

**Important**: Always use `Application Context`, never `Activity Context`.

### 4. Create Local Config File

Create `assets/ads_config.json` in your app module:

```json
{
  "ads": {
    "global": {
      "enable": true,
      "cmp_auto": true,
      "min_interval": 30000
    },
    "spaces": [
      {
        "space": "ADMOB_Banner_Home",
        "adsType": "banner",
        "ids": ["ca-app-pub-3940256099942544/6300978111"],
        "enable": true,
        "minInterval": 30000
      },
      {
        "space": "ADMOB_Native_List",
        "adsType": "native",
        "ids": ["ca-app-pub-3940256099942544/2247696110"],
        "enable": true,
        "minInterval": 30000
      },
      {
        "space": "ADMOB_Interstitial_General",
        "adsType": "interstitial",
        "ids": ["ca-app-pub-3940256099942544/1033173712"],
        "enable": true,
        "minInterval": 30000
      },
      {
        "space": "ADMOB_Rewarded_Video",
        "adsType": "reward",
        "ids": ["ca-app-pub-3940256099942544/5224354917"],
        "enable": true,
        "minInterval": 30000
      }
    ]
  }
}
```

**Config Fields**:
- `space`: Unique identifier for ad placement
- `adsType`: Ad type (`banner`, `native`, `interstitial`, `reward`, `reward_inter`, `open_app`)
- `ids`: Waterfall ad unit IDs (tries in order until success)
- `enable`: Enable/disable this space
- `minInterval`: Minimum milliseconds between shows

## Ad Integration by Type

For detailed implementation of each ad type, see:

- **Banner Ads**: See [references/banner.md](references/banner.md)
- **Native Ads**: See [references/native.md](references/native.md)
- **Interstitial Ads**: See [references/interstitial.md](references/interstitial.md)
- **Rewarded Ads**: See [references/rewarded.md](references/rewarded.md)
- **Rewarded Interstitial Ads**: See [references/rewarded-interstitial.md](references/rewarded-interstitial.md)
- **Open App Ads**: See [references/open-app.md](references/open-app.md)

## Advanced Configuration

For advanced features, see:

- **CMP Consent Management**: See [references/cmp.md](references/cmp.md) - GDPR/UMP consent flow, loading dialog, privacy options
- **Firebase Remote Config**: See [references/remote-config.md](references/remote-config.md) - Remote configuration override
- **App Resume Ads**: See [references/resume-ads.md](references/resume-ads.md) - Open app ads on resume
- **Event Handling**: See [references/events.md](references/events.md) - Global event bus subscription

## Critical Rules

1. **Package Name**: Always import from `com.admob.adspace.*`, not `io.github.maichanchinh.*`
2. **Thread Safety**: All Space classes are thread-safe
3. **Memory Management**: Clear cache on Activity destroy
4. **Premium Check**: Check user premium status before showing ads
5. **Min Interval**: SDK enforces minimum interval between shows
6. **CMP Gate**: Ads blocked until consent obtained (if required)
7. **Waterfall Strategy**: SDK tries ad unit IDs in order automatically

## Common Patterns

```kotlin
// Check if ad is ready
SpaceInterstitial.isLoaded("ADMOB_Interstitial_General")

// Preload ads
SpaceInterstitial.preload("ADMOB_Interstitial_General", callback)
SpaceRewarded.preload("ADMOB_Rewarded_Video", callback)

// Clear cache
SpaceBanner.clearCache("ADMOB_Banner_Home")
SpaceBanner.clearAllCache()

// Disable ad type globally
AdSpaceSDK.setAdTypeEnabled(AdsType.BANNER, false)
```

## Troubleshooting

**Ads not showing?**
1. Check `ads.global.enable` is `true` in config
2. Check space-specific `enable` is `true`
3. Verify AdMob App ID in manifest
4. Check min interval hasn't blocked the ad
5. Verify CMP consent obtained (if required)
6. Check user premium status

**Memory leaks?**
1. Always clear cache in `onDestroy()`
2. Use `WeakReference` for Activity contexts
3. Don't hold references to AdView/NativeAdView

**Wrong package imports?**
1. Use `com.admob.adspace.*` not `io.github.maichanchinh.*`
2. Check import statements match examples above
