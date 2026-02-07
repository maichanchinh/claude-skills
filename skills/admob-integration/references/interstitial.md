# Interstitial Ads Integration

Interstitial ads are full-screen ads that cover the interface of the app.

## Package Imports

```kotlin
import com.admob.adspace.interstitial.SpaceInterstitial
import com.admob.adspace.interstitial.InterstitialCallback
import com.admob.adspace.interstitial.InterstitialError
```

## Basic Implementation

```kotlin
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.admob.adspace.interstitial.SpaceInterstitial
import com.admob.adspace.interstitial.InterstitialCallback
import com.admob.adspace.interstitial.InterstitialError

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Preload interstitial
        preloadInterstitial()

        // Show on button click
        binding.btnShowAd.setOnClickListener {
            showInterstitial()
        }
    }

    private fun preloadInterstitial() {
        SpaceInterstitial.preload(
            space = "ADMOB_Interstitial_General",
            forceRefresh = false,
            callback = object : InterstitialCallback {
                override fun onLoaded(space: String) {
                    // Ad loaded and ready
                }

                override fun onFailed(space: String, error: InterstitialError) {
                    // Failed to load
                }

                override fun onShowed(space: String) {
                    // Ad displayed
                }

                override fun onDismissed(space: String) {
                    // Ad dismissed, preload next ad
                    preloadInterstitial()
                }

                override fun onClicked(space: String) {
                    // Ad clicked
                }

                override fun onImpression(space: String) {
                    // Impression recorded
                }

                override fun onPaid(space: String, revenue: AdRevenue) {
                    // Revenue: revenue.value
                }
            }
        )
    }

    private fun showInterstitial() {
        SpaceInterstitial.show(
            space = "ADMOB_Interstitial_General",
            activity = this,
            forceShow = false,
            loadIfNotAvailable = true,
            showLoading = true,
            customLoadingView = null,
            callback = object : InterstitialCallback {
                override fun onLoaded(space: String) {}
                override fun onFailed(space: String, error: InterstitialError) {}
                override fun onShowed(space: String) {}
                override fun onDismissed(space: String) {
                    // Continue app flow
                }
                override fun onClicked(space: String) {}
                override fun onImpression(space: String) {}
                override fun onPaid(space: String, revenue: AdRevenue) {}
            }
        )
    }
}
```

## Show Methods

### Show with Auto-Load

Automatically loads ad if not available:

```kotlin
SpaceInterstitial.show(
    space = "ADMOB_Interstitial_General",
    activity = this,
    forceShow = false,
    loadIfNotAvailable = true,
    showLoading = true,
    callback = callback
)
```

### Show Only if Loaded

Only shows if ad is already loaded:

```kotlin
SpaceInterstitial.show(
    space = "ADMOB_Interstitial_General",
    activity = this,
    forceShow = false,
    loadIfNotAvailable = false,
    showLoading = false,
    callback = callback
)
```

### Force Show (Bypass Min Interval)

```kotlin
SpaceInterstitial.show(
    space = "ADMOB_Interstitial_General",
    activity = this,
    forceShow = true, // Bypass min interval check
    loadIfNotAvailable = true,
    showLoading = true,
    callback = callback
)
```

### Custom Loading View

```kotlin
val customLoading = layoutInflater.inflate(R.layout.custom_loading, null)

SpaceInterstitial.show(
    space = "ADMOB_Interstitial_General",
    activity = this,
    forceShow = false,
    loadIfNotAvailable = true,
    showLoading = true,
    customLoadingView = customLoading,
    callback = callback
)
```

## Advanced Features

### Check if Ad is Ready

```kotlin
if (SpaceInterstitial.isLoaded("ADMOB_Interstitial_General")) {
    // Ad is ready to show
    showInterstitial()
} else {
    // Preload ad
    preloadInterstitial()
}
```

### Clear Cache

```kotlin
SpaceInterstitial.clearCache("ADMOB_Interstitial_General")
```

## Configuration

In `assets/ads_config.json`:

```json
{
  "space": "ADMOB_Interstitial_General",
  "adsType": "interstitial",
  "ids": [
    "ca-app-pub-3940256099942544/1033173712",
    "ca-app-pub-3940256099942544/8691691433"
  ],
  "enable": true,
  "minInterval": 60000
}
```

## Best Practices

1. **Preload early** - Load ads before you need them
2. **Show at natural breaks** - Between levels, after actions
3. **Reload after dismiss** - Preload next ad immediately
4. **Use loading dialog** - Better UX while loading
5. **Respect min interval** - Don't spam users with ads
6. **Check if loaded** - Before showing to avoid delays
7. **Handle failures gracefully** - Continue app flow if ad fails

## Common Patterns

### Show Between Levels

```kotlin
fun onLevelComplete() {
    // Show interstitial after level
    SpaceInterstitial.show(
        space = "ADMOB_Interstitial_Level",
        activity = this,
        loadIfNotAvailable = true,
        showLoading = true,
        callback = object : InterstitialCallback {
            override fun onDismissed(space: String) {
                // Continue to next level
                startNextLevel()
            }
            override fun onFailed(space: String, error: InterstitialError) {
                // Continue anyway
                startNextLevel()
            }
            // ... other callbacks
        }
    )
}
```

### Preload on App Start

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize SDK
        AdSpaceSDK.initialize(this, config)

        // Preload interstitial
        SpaceInterstitial.preload(
            space = "ADMOB_Interstitial_General",
            callback = callback
        )
    }
}
```

## Common Issues

**Ad not showing?**
- Check if ad is loaded with `isLoaded()`
- Verify min interval hasn't blocked the ad
- Check space is enabled in config
- Ensure Activity is not finishing

**Loading takes too long?**
- Preload ads early
- Use loading dialog for better UX
- Consider waterfall with multiple ad unit IDs

**Ad shows too frequently?**
- Increase `minInterval` in config
- Don't use `forceShow = true` unless necessary
