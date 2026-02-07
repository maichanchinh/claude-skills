# Open App Ads Integration

Open app ads are shown when users open or return to your app.

## Package Imports

```kotlin
import com.admob.adspace.open.SpaceOpenApp
import com.admob.adspace.open.OpenAppCallback
import com.admob.adspace.open.OpenAppError
```

## Basic Implementation

```kotlin
import android.app.Application
import com.admob.adspace.AdSpaceSDK
import com.admob.adspace.open.SpaceOpenApp
import com.admob.adspace.open.OpenAppCallback
import com.admob.adspace.open.OpenAppError

class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        // Initialize SDK
        AdSpaceSDK.initialize(this, config)

        // Preload open app ad
        preloadOpenAppAd()
    }

    private fun preloadOpenAppAd() {
        SpaceOpenApp.preload(
            space = "ADMOB_OpenApp_General",
            forceRefresh = false,
            callback = object : OpenAppCallback {
                override fun onLoaded(space: String) {
                    // Ad loaded
                }

                override fun onFailed(space: String, error: OpenAppError) {
                    // Failed to load
                }

                override fun onShowed(space: String) {
                    // Ad displayed
                }

                override fun onDismissed(space: String) {
                    // Preload next ad
                    preloadOpenAppAd()
                }

                override fun onClicked(space: String) {
                    // Ad clicked
                }

                override fun onImpression(space: String) {
                    // Impression recorded
                }

                override fun onPaid(space: String, revenue: AdRevenue) {
                    // Revenue received
                }
            }
        )
    }
}
```

## Manual Show

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onResume() {
        super.onResume()

        // Show open app ad manually
        SpaceOpenApp.show(
            space = "ADMOB_OpenApp_General",
            activity = this,
            forceShow = false,
            loadIfNotAvailable = true,
            callback = object : OpenAppCallback {
                override fun onLoaded(space: String) {}
                override fun onFailed(space: String, error: OpenAppError) {}
                override fun onShowed(space: String) {}
                override fun onDismissed(space: String) {}
                override fun onClicked(space: String) {}
                override fun onImpression(space: String) {}
                override fun onPaid(space: String, revenue: AdRevenue) {}
            }
        )
    }
}
```

## Configuration

In `assets/ads_config.json`:

```json
{
  "space": "ADMOB_OpenApp_General",
  "adsType": "open_app",
  "ids": [
    "ca-app-pub-3940256099942544/9257395921"
  ],
  "enable": true,
  "minInterval": 240000
}
```

## Best Practices

1. **Preload in Application.onCreate()** - Load early
2. **Higher min interval** - 4+ minutes recommended
3. **Exclude certain screens** - Don't show on splash/login
4. **Check if loaded** - Before showing
5. **Reload after dismiss** - Preload next ad

## Advanced Features

### Check if Ad is Ready

```kotlin
if (SpaceOpenApp.isLoaded("ADMOB_OpenApp_General")) {
    // Ad is ready
}
```

### Clear Cache

```kotlin
SpaceOpenApp.clearCache("ADMOB_OpenApp_General")
```

## Common Issues

**Ad shows too frequently?**
- Increase `minInterval` to 240000 (4 minutes) or higher
- SDK enforces min interval automatically

**Ad shows on wrong screens?**
- Use app resume ads instead (see [resume-ads.md](resume-ads.md))
- Implement manual show logic with screen checks
