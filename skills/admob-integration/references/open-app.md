# Open App Ads Integration

Open app ads are shown when users open or return to your app. AdSpaceSDK provides two types:

1. **SpaceOpenSplash** - For splash screen with timeout support
2. **SpaceOpenResume** - For automatic show on app resume

## Package Imports

```kotlin
// Splash Screen Open App Ads
import com.admob.adspace.open.SpaceOpenSplash
import com.admob.adspace.open.OpenCallback
import com.admob.adspace.open.OpenError

// Resume Open App Ads
import com.admob.adspace.open.SpaceOpenResume
```

## SpaceOpenSplash

Open app ads for splash screen with timeout support. Automatically loads, shows ad, and calls nextAction when ad is dismissed or timeout reached.

### Basic Implementation

```kotlin
import android.app.Activity
import com.admob.adspace.open.SpaceOpenSplash

class SplashActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        // Show open app splash ad with timeout
        SpaceOpenSplash.show(
            space = "ADMOB_Open_Splash",
            activity = this,
            timeoutMs = 15_000L, // 15 seconds timeout
            callback = null,
            nextAction = {
                // Navigate to main screen
                navigateToMain()
            }
        )
    }

    private fun navigateToMain() {
        startActivity(Intent(this, MainActivity::class.java))
        finish()
    }
}
```

### With Custom Callback

```kotlin
SpaceOpenSplash.show(
    space = "ADMOB_Open_Splash",
    activity = this,
    timeoutMs = 10_000L,
    callback = object : OpenCallback {
        override fun onLoaded(space: String) {
            Timber.d("Open app splash ad loaded")
        }

        override fun onFailed(space: String, error: OpenError) {
            Timber.e("Open app splash ad failed: ${error.message}")
            // Will still call nextAction
        }

        override fun onImpression(space: String) {
            Timber.d("Open app splash ad impression")
        }

        override fun onClicked(space: String) {
            Timber.d("Open app splash ad clicked")
        }

        override fun onPaid(space: String, revenue: AdRevenue) {
            Timber.d("Open app splash ad revenue: ${revenue.value}")
        }

        override fun onDismissed(space: String) {
            Timber.d("Open app splash ad dismissed")
        }

        override fun onAdLeftApplication(space: String) {
            Timber.d("Open app splash ad left application")
        }
    },
    nextAction = {
        navigateToMain()
    }
)
```

### Cancel Splash Operation

```kotlin
override fun onDestroy() {
    super.onDestroy()
    // Cancel splash ad operation if activity is destroyed
    SpaceOpenSplash.cancel()
}
```

### Check if Ad is Loaded

```kotlin
if (SpaceOpenSplash.isLoaded("ADMOB_Open_Splash")) {
    // Ad is loaded and ready to show
}
```

### API Methods

| Method | Parameters | Return | Description |
|--------|------------|--------|-------------|
| `show()` | space, activity, timeoutMs, callback, nextAction | Unit | Show splash ad with timeout |
| `isLoaded()` | space: String | Boolean | Check if ad is loaded |
| `cancel()` | - | Unit | Cancel current splash operation |

### Configuration

In `assets/ads_config.json`:

```json
{
  "space": "ADMOB_Open_Splash",
  "adsType": "open_app",
  "ids": [
    "ca-app-pub-3940256099942544/9257395921"
  ],
  "enable": true,
  "minInterval": 300000
}
```

**Note**: Use higher `minInterval` (5 minutes) for open app splash ads.

---

## SpaceOpenResume

Open app ads that automatically show when app returns from background (resume mode).

### Basic Implementation

```kotlin
import android.app.Application
import com.admob.adspace.AdSpaceSDK
import com.admob.adspace.open.SpaceOpenResume

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize SDK
        AdSpaceSDK.initialize(this, config)

        // Register and load open app resume ads
        SpaceOpenResume.registerAndLoad(
            space = "ADMOB_Open_Resume",
            callback = object : OpenCallback {
                override fun onLoaded(space: String) {
                    Timber.d("Open app resume ad loaded")
                }

                override fun onFailed(space: String, error: OpenError) {
                    Timber.e("Open app resume ad failed: ${error.message}")
                }

                override fun onImpression(space: String) {
                    Timber.d("Open app resume impression")
                }

                override fun onClicked(space: String) {
                    Timber.d("Open app resume clicked")
                }

                override fun onPaid(space: String, revenue: AdRevenue) {
                    Timber.d("Open app resume revenue: ${revenue.value}")
                }

                override fun onDismissed(space: String) {
                    Timber.d("Open app resume dismissed")
                }

                override fun onAdLeftApplication(space: String) {
                    Timber.d("Open app resume left application")
                }
            }
        )
    }
}
```

### Exclude Activities

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        AdSpaceSDK.initialize(this, config)

        // Enable open app resume ads
        SpaceOpenResume.registerAndLoad(
            space = "ADMOB_Open_Resume",
            callback = callback
        )

        // Exclude activities from showing resume ads
        AdSpaceSDK.setIgnoreAdResume(SplashActivity::class.java)
        AdSpaceSDK.setIgnoreAdResume(LoginActivity::class.java)
        AdSpaceSDK.setIgnoreAdResume(OnboardingActivity::class.java)
    }
}
```

### Skip Next Show

```kotlin
class PaymentActivity : AppCompatActivity() {

    private fun processPayment() {
        // Skip next resume ad after payment
        AdSpaceSDK.skipNextShow()

        // Process payment
        processPaymentInternal()
    }
}
```

### Check Status

```kotlin
// Check if ad is loaded
val isLoaded = SpaceOpenResume.isLoaded("ADMOB_Open_Resume")

// Check if ad is ready (loaded + interval passed)
val isReady = SpaceOpenResume.isReady("ADMOB_Open_Resume")
```

### Unregister Resume Mode

```kotlin
// Disable open app resume ads
SpaceOpenResume.unregister()

// Or use AdSpaceSDK API
AdSpaceSDK.setResumeMode(AdSpaceSDK.ResumeMode.NONE, "")
```

### Preload Manually

```kotlin
// Preload open app ad without showing
SpaceOpenResume.preload(
    space = "ADMOB_Open_Resume",
    forceRefresh = false,
    callback = callback
)
```

### Clear Cache

```kotlin
// Clear specific space
SpaceOpenResume.clearCache("ADMOB_Open_Resume")

// Clear all cache
SpaceOpenResume.clearAllCache()
```

### API Methods

| Method | Parameters | Return | Description |
|--------|------------|--------|-------------|
| `registerAndLoad()` | space: String, callback: OpenCallback? | Unit | Register and load ad for automatic showing |
| `unregister()` | - | Unit | Unregister from resume mode |
| `preload()` | space, forceRefresh, callback | Unit | Preload ad without showing |
| `onAppResume()` | activity: Activity, onComplete: OnShowAdCompleteListener | Unit | Called automatically on app resume |
| `skipNextShow()` | - | Unit | Skip the next resume ad show |
| `isLoaded()` | space: String | Boolean | Check if ad is loaded |
| `isReady()` | space: String | Boolean | Check if ad is ready to show |
| `clearCache()` | space: String | Unit | Clear cached ad |
| `clearAllCache()` | - | Unit | Clear all cache |
| `getSpaceName()` | - | String? | Get current space name |
| `getResumeMode()` | - | ResumeMode | Get resume mode (OPEN_ADS) |

### Configuration

In `assets/ads_config.json`:

```json
{
  "space": "ADMOB_Open_Resume",
  "adsType": "open_app",
  "ids": [
    "ca-app-pub-3940256099942544/9257395921"
  ],
  "enable": true,
  "minInterval": 240000
}
```

**Note**: Use 3-4 minutes (240000ms) for `minInterval` to avoid annoying users.

## SpaceOpenSplash vs SpaceOpenResume

| Feature | SpaceOpenSplash | SpaceOpenResume |
|---------|-----------------|-----------------|
| **Use Case** | Splash screen on app cold start | App resume from background |
| **Timeout** | Yes (configurable, default 15s) | No timeout |
| **Next Action** | Required callback | Automatic via resume mode |
| **Manual Control** | Show manually | Automatic show on resume |
| **Lifecycle** | Single show per call | Can show multiple times |
| **Cache** | No caching between calls | Caches ad for resume |

## Best Practices

### SpaceOpenSplash

1. **Appropriate timeout** - Use 10-15 seconds
2. **Handle timeout gracefully** - Always call nextAction even if timeout
3. **Don't block app** - App should work without splash ad
4. **Cancel on destroy** - Call `cancel()` in Activity.onDestroy()

### SpaceOpenResume

1. **Higher min interval** - 3-4 minutes recommended
2. **Exclude key screens** - Don't show on splash, login, payment
3. **Use skipNextShow()** - Skip after critical user actions
4. **Monitor metrics** - Track user retention and session length
5. **Test thoroughly** - Verify ads don't disrupt critical flows

## Common Patterns

### Pattern 1: Exclude Multiple Activities

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        AdSpaceSDK.initialize(this, config)

        // Enable open app resume ads
        SpaceOpenResume.registerAndLoad(
            space = "ADMOB_Open_Resume",
            callback = callback
        )

        // Exclude multiple activities
        val excludedActivities = listOf(
            SplashActivity::class.java,
            LoginActivity::class.java,
            OnboardingActivity::class.java,
            PaymentActivity::class.java,
            VideoPlayerActivity::class.java
        )

        excludedActivities.forEach { activityClass ->
            AdSpaceSDK.setIgnoreAdResume(activityClass)
        }
    }
}
```

### Pattern 2: Skip After User Action

```kotlin
class MainActivity : AppCompatActivity() {

    override fun onDestroy() {
        super.onDestroy()

        // Skip next resume ad after user completes important action
        if (userCompletedImportantAction) {
            AdSpaceSDK.skipNextShow()
        }
    }
}
```

### Pattern 3: Dynamic Toggle

```kotlin
class SettingsActivity : AppCompatActivity() {

    private fun updateResumeAdSettings(enabled: Boolean) {
        if (enabled) {
            // Re-enable with default space
            SpaceOpenResume.registerAndLoad(
                space = "ADMOB_Open_Resume",
                callback = null
            )
        } else {
            // Disable resume ads
            SpaceOpenResume.unregister()
        }
    }
}
```

### Pattern 4: Splash with Fallback

```kotlin
class SplashActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        // Try to show splash ad with timeout
        SpaceOpenSplash.show(
            space = "ADMOB_Open_Splash",
            activity = this,
            timeoutMs = 10_000L,
            callback = createSplashCallback(),
            nextAction = {
                // Always navigate to main, with or without ad
                navigateToMain()
            }
        )
    }

    private fun navigateToMain() {
        startActivity(Intent(this, MainActivity::class.java))
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        SpaceOpenSplash.cancel()
    }
}
```

## Common Issues

**Open app ads showing too frequently?**
- Increase `minInterval` to 240000 (4 minutes) or higher
- SDK enforces min interval automatically

**Open app ads showing on wrong screens?**
- Use `AdSpaceSDK.setIgnoreAdResume()` to exclude activities
- Exclude splash, login, payment, video player screens

**Open app ads not showing?**
- Check resume mode is set correctly via `AdSpaceSDK.getActiveResumeMode()`
- Verify space is enabled in config
- Check min interval hasn't blocked the ad
- Ensure activity is not in excluded list
- Check ad is loaded with `isLoaded()` and ready with `isReady()`

**Splash timeout not working?**
- Timeout is in milliseconds (15_000 = 15 seconds)
- nextAction is always called, even on timeout
- Cancel operation with `SpaceOpenSplash.cancel()` if needed

**Resume ads showing immediately after cold start?**
- This is expected behavior on first resume
- Use higher min interval to avoid
- Exclude splash activity from resume ads

## Comparison: Open App vs Interstitial Resume

| Feature | SpaceOpenResume | SpaceInterstitialResume |
|---------|-----------------|-------------------------|
| **Ad Type** | Open app ads | Interstitial ads |
| **Resume Mode** | `ResumeMode.OPEN_ADS` | `ResumeMode.INTERSTITIAL` |
| **Welcome Dialog** | No dialog | Shows "Welcome back" dialog |
| **User Experience** | Less intrusive, more natural | More intrusive |
| **Revenue** | Typically higher (campaign ads) | Standard interstitial revenue |
| **Use Case** | General app resuming | When you want more control |
