# Banner Ads Integration

Banner ads are rectangular ads that appear at the top or bottom of the screen.

## Package Imports

```kotlin
import com.admob.adspace.banner.SpaceBanner
import com.admob.adspace.banner.BannerCallback
import com.admob.adspace.banner.BannerError
import com.admob.adspace.banner.AdRevenue
import com.google.android.libraries.ads.mobile.sdk.banner.AdView
import com.google.android.libraries.ads.mobile.sdk.banner.AdSize
```

## View API (XML/Kotlin)

### Layout XML

```xml
<FrameLayout
    android:id="@+id/bannerContainer"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="#E0E0E0"/>
```

### Basic Implementation

```kotlin
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import com.admob.adspace.banner.SpaceBanner
import com.admob.adspace.banner.BannerCallback
import com.admob.adspace.banner.BannerError
import com.admob.adspace.banner.AdRevenue
import com.google.android.libraries.ads.mobile.sdk.banner.AdView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Show inline adaptive banner
        SpaceBanner.showInlineAdaptive(
            space = "ADMOB_Banner_Home",
            viewGroup = binding.bannerContainer,
            forceRefresh = false,
            center = true,
            callback = object : BannerCallback {
                override fun onLoaded(adView: AdView, space: String) {
                    // Banner loaded successfully
                }

                override fun onFailed(space: String, error: BannerError) {
                    // Hide container on failure
                    binding.bannerContainer.visibility = View.GONE
                }

                override fun onImpression(space: String) {
                    // Banner impression recorded
                }

                override fun onClicked(space: String) {
                    // Banner clicked
                }

                override fun onPaid(space: String, revenue: AdRevenue) {
                    // Revenue received: revenue.value, revenue.currencyCode
                }

                override fun onCollapsed(space: String, position: CollapsiblePosition) {
                    // Banner collapsed (for collapsible banners only)
                }
            }
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        SpaceBanner.clearCache("ADMOB_Banner_Home")
    }
}
```

## Banner Types

### 1. Inline Adaptive Banner

Best for scrollable content (lists, feeds):

```kotlin
SpaceBanner.showInlineAdaptive(
    space = "ADMOB_Banner_Home",
    viewGroup = binding.bannerContainer,
    forceRefresh = false,
    center = true,
    callback = callback
)
```

### 2. Anchored Adaptive Banner

Best for fixed position (top/bottom of screen):

```kotlin
SpaceBanner.showAnchoredAdaptive(
    space = "ADMOB_Banner_Home",
    viewGroup = binding.bannerContainer,
    forceRefresh = false,
    center = true,
    callback = callback
)
```

### 3. Collapsible Banner

Banner with close button:

```kotlin
import com.admob.adspace.banner.CollapsiblePosition

SpaceBanner.showCollapsible(
    space = "ADMOB_Banner_Home",
    viewGroup = binding.bannerContainer,
    position = CollapsiblePosition.BOTTOM, // or TOP
    forceRefresh = false,
    center = true,
    callback = callback
)
```

### 4. Fixed Size Banner

Legacy fixed-size banner:

```kotlin
import com.google.android.libraries.ads.mobile.sdk.banner.AdSize

SpaceBanner.show(
    space = "ADMOB_Banner_Home",
    viewGroup = binding.bannerContainer,
    adSize = AdSize.BANNER, // 320x50
    forceRefresh = false,
    center = true,
    callback = callback
)
```

**Common AdSize values**:
- `AdSize.BANNER` - 320x50
- `AdSize.LARGE_BANNER` - 320x100
- `AdSize.MEDIUM_RECTANGLE` - 300x250
- `AdSize.FULL_BANNER` - 468x60
- `AdSize.LEADERBOARD` - 728x90

## Jetpack Compose API

```kotlin
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import com.admob.adspace.banner.SpaceBanner
import com.admob.adspace.banner.BannerCallback
import com.admob.adspace.banner.BannerError
import com.admob.adspace.banner.AdRevenue
import com.google.android.libraries.ads.mobile.sdk.banner.AdView

@Composable
fun BannerAd(
    space: String,
    modifier: Modifier = Modifier,
    forceRefresh: Boolean = false
) {
    AndroidView(
        factory = { context ->
            android.widget.FrameLayout(context).apply {
                layoutParams = android.widget.FrameLayout.LayoutParams(
                    android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
                    android.widget.FrameLayout.LayoutParams.WRAP_CONTENT
                )
            }
        },
        modifier = modifier,
        update = { frameLayout ->
            SpaceBanner.showInlineAdaptive(
                space = space,
                viewGroup = frameLayout,
                forceRefresh = forceRefresh,
                center = true,
                callback = object : BannerCallback {
                    override fun onLoaded(adView: AdView, space: String) {}
                    override fun onFailed(space: String, error: BannerError) {}
                    override fun onImpression(space: String) {}
                    override fun onClicked(space: String) {}
                    override fun onPaid(space: String, revenue: AdRevenue) {}
                    override fun onCollapsed(space: String, position: CollapsiblePosition) {}
                }
            )
        }
    )

    DisposableEffect(space) {
        onDispose {
            SpaceBanner.clearCache(space)
        }
    }
}

// Usage
@Composable
fun HomeScreen() {
    Column {
        Text("Content")
        BannerAd(space = "ADMOB_Banner_Home")
    }
}
```

## Advanced Features

### Preload Banner

```kotlin
SpaceBanner.preload(
    space = "ADMOB_Banner_Home",
    forceRefresh = false,
    callback = callback
)
```

### Check if Banner is Loaded

```kotlin
if (SpaceBanner.isLoaded("ADMOB_Banner_Home")) {
    // Banner is ready
}
```

### Clear Cache

```kotlin
// Clear specific space
SpaceBanner.clearCache("ADMOB_Banner_Home")

// Clear all banner cache
SpaceBanner.clearAllCache()
```

## Configuration

In `assets/ads_config.json`:

```json
{
  "space": "ADMOB_Banner_Home",
  "adsType": "banner",
  "ids": [
    "ca-app-pub-3940256099942544/6300978111",
    "ca-app-pub-3940256099942544/2934735716"
  ],
  "enable": true,
  "minInterval": 30000
}
```

## Best Practices

1. **Always clear cache in onDestroy()** to prevent memory leaks
2. **Hide container on failure** to avoid empty space
3. **Use adaptive banners** instead of fixed sizes for better fill rates
4. **Center banners** for better visual appearance
5. **Don't create too many banner instances** - reuse when possible
6. **Respect min interval** - SDK enforces this automatically
7. **Check premium status** before showing ads

## Common Issues

**Banner not showing?**
- Check space is enabled in config
- Verify AdMob App ID in manifest
- Check min interval hasn't blocked the ad
- Verify test device ID is correct (for testing)

**Memory leak?**
- Always call `clearCache()` in `onDestroy()`
- Don't hold references to AdView

**Wrong size?**
- Use `showInlineAdaptive()` for scrollable content
- Use `showAnchoredAdaptive()` for fixed position
- Ensure container has proper layout params
