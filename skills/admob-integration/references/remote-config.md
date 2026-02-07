# Firebase Remote Config Integration

Firebase Remote Config allows you to remotely control ad behavior without app updates.

## Package Imports

```kotlin
import com.google.firebase.Firebase
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import com.google.firebase.remoteconfig.remoteConfig
import com.google.firebase.remoteconfig.remoteConfigSettings
```

## Setup

### 1. Add Firebase to Project

Add Firebase dependencies to app module's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("io.github.maichanchinh:adspace-admob:2.0.0")

    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-config-ktx")
}
```

Add `google-services.json` to your app module.

### 2. Initialize SDK with Remote Config

```kotlin
import android.app.Application
import com.admob.adspace.AdSpaceSDK
import com.admob.adspace.AdSpaceSDKConfig
import com.google.firebase.Firebase
import com.google.firebase.remoteconfig.remoteConfig
import com.google.firebase.remoteconfig.remoteConfigSettings

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Configure Firebase Remote Config
        val remoteConfig = Firebase.remoteConfig
        val configSettings = remoteConfigSettings {
            minimumFetchIntervalInSeconds = 3600 // 1 hour
        }
        remoteConfig.setConfigSettingsAsync(configSettings)

        // Initialize AdSpaceSDK with Remote Config
        val config = AdSpaceSDKConfig(
            debug = BuildConfig.DEBUG,
            testDevices = emptyList(),
            minInterval = 30L,
            appId = "ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY",
            remoteConfig = remoteConfig // Pass Firebase Remote Config
        )

        AdSpaceSDK.initialize(this, config)
    }
}
```

## Remote Config Parameters

### Global Parameters

Set these in Firebase Console:

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `ads.global.enable` | Boolean | Global ad kill switch | `true` |
| `ads.global.cmp_auto` | Boolean | Auto-display CMP consent | `true` |
| `ads.global.min_interval` | Number | Global min interval (ms) | `30000` |

### Space-Specific Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `ads.{space}.enable` | Boolean | Enable/disable space | `true` |
| `ads.{space}.min_interval` | Number | Space min interval (ms) | `60000` |
| `ads.{space}.admob_id` | String | Waterfall ad unit IDs | `id1\|id2\|id3` |

**IMPORTANT**: Remote config CANNOT change `adsType`. This is immutable and defined in local config only.

## Remote Config Examples

### Example 1: Global Kill Switch

In Firebase Console, set:
```
ads.global.enable = false
```

This disables ALL ads across the app without requiring an app update.

### Example 2: Disable Specific Space

```
ads.ADMOB_Banner_Home.enable = false
```

This disables only the home banner while keeping other ads active.

### Example 3: Update Ad Unit IDs

```
ads.ADMOB_Interstitial_General.admob_id = "ca-app-pub-XXX/111|ca-app-pub-XXX/222|ca-app-pub-XXX/333"
```

This updates the waterfall ad unit IDs remotely. Use pipe `|` to separate multiple IDs.

### Example 4: Increase Min Interval

```
ads.ADMOB_Interstitial_General.min_interval = 120000
```

This increases the minimum interval to 2 minutes for interstitial ads.

## Config Merge Logic

AdSpaceSDK merges local and remote configs with these rules:

1. **Local config is base** - Always loaded first from `assets/ads_config.json`
2. **Remote overrides allowed fields** - Only specific fields can be overridden
3. **adsType is immutable** - Cannot be changed remotely
4. **Waterfall IDs are replaced** - Remote IDs completely replace local IDs

### Merge Priority

```
Remote Config > Local Config > SDK Defaults
```

## Best Practices

1. **Set reasonable fetch interval** - 1 hour (3600s) recommended
2. **Test in debug mode** - Use shorter fetch interval for testing
3. **Use global kill switch** - For emergency ad disabling
4. **Monitor metrics** - Track impact of remote config changes
5. **Gradual rollout** - Use Firebase A/B testing for changes
6. **Keep local config complete** - Remote config is optional override

## Testing Remote Config

### Debug Mode

For testing, use shorter fetch interval:

```kotlin
val configSettings = remoteConfigSettings {
    minimumFetchIntervalInSeconds = if (BuildConfig.DEBUG) 0 else 3600
}
```

### Force Fetch

```kotlin
remoteConfig.fetchAndActivate().addOnCompleteListener { task ->
    if (task.isSuccessful) {
        // Config fetched and activated
    }
}
```

## Common Patterns

### A/B Testing Ad Frequency

Use Firebase Remote Config with A/B testing:

1. Create experiment in Firebase Console
2. Set different `min_interval` values for variants
3. Monitor user retention and revenue metrics

### Emergency Ad Disable

```kotlin
// In Firebase Console, set:
ads.global.enable = false

// All ads will be disabled within fetch interval
// No app update required
```

### Seasonal Ad Adjustments

```kotlin
// Black Friday: Increase ad frequency
ads.global.min_interval = 15000

// Post-holiday: Decrease frequency
ads.global.min_interval = 60000
```

## Common Issues

**Remote config not applying?**
- Check fetch interval hasn't blocked update
- Verify parameter names match exactly
- Check Firebase Console for parameter values
- Call `fetchAndActivate()` to force update

**Ads still showing after disabling?**
- Wait for fetch interval to elapse
- Check local config isn't overriding
- Verify `ads.global.enable` is set correctly

**Wrong ad unit IDs?**
- Use pipe `|` separator, not comma
- Verify IDs are correct in Firebase Console
- Check merge logic is working correctly
