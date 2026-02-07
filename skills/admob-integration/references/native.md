# Native Ads Integration

Native ads match the look and feel of your app's content.

## Package Imports

```kotlin
import com.admob.adspace.native.SpaceNative
import com.admob.adspace.native.NativeCallback
import com.admob.adspace.native.NativeError
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
```

## Basic Implementation

### Layout XML

```xml
<FrameLayout
    android:id="@+id/nativeContainer"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:minHeight="200dp"/>
```

### Kotlin Code

```kotlin
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import com.admob.adspace.native.SpaceNative
import com.admob.adspace.native.NativeCallback
import com.admob.adspace.native.NativeError
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Show medium native ad
        SpaceNative.showMedium(
            space = "ADMOB_Native_List",
            viewGroup = binding.nativeContainer,
            layoutRes = R.layout.layout_native_medium,
            callback = object : NativeCallback {
                override fun onLoaded(nativeAdView: NativeAdView, nativeAd: NativeAd, space: String) {
                    // Ad loaded successfully
                }

                override fun onFailed(space: String, error: NativeError) {
                    // Hide container on failure
                    binding.nativeContainer.visibility = View.GONE
                }

                override fun onImpression(space: String) {
                    // Impression recorded
                }

                override fun onClicked(space: String) {
                    // Ad clicked
                }

                override fun onPaid(space: String, revenue: NativeRevenue) {
                    // Revenue: revenue.valueMicros
                }
            }
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        SpaceNative.clearCache("ADMOB_Native_List")
    }
}
```

## Native Ad Sizes

### 1. Small Native Ad

Compact layout for lists:

```kotlin
SpaceNative.showSmall(
    space = "ADMOB_Native_List",
    viewGroup = binding.nativeContainer,
    layoutRes = R.layout.layout_native_small,
    callback = callback
)
```

### 2. Medium Native Ad

Standard layout:

```kotlin
SpaceNative.showMedium(
    space = "ADMOB_Native_List",
    viewGroup = binding.nativeContainer,
    layoutRes = R.layout.layout_native_medium,
    callback = callback
)
```

### 3. Large Native Ad

Detailed layout with more content:

```kotlin
SpaceNative.showLarge(
    space = "ADMOB_Native_List",
    viewGroup = binding.nativeContainer,
    layoutRes = R.layout.layout_native_large,
    callback = callback
)
```

### 4. Fullscreen Native Ad

Full-screen layout:

```kotlin
SpaceNative.showFullscreen(
    space = "ADMOB_Native_List",
    viewGroup = binding.nativeContainer,
    layoutRes = R.layout.layout_native_fullscreen,
    callback = callback
)
```

## Custom Native Ad Layout

Create custom layout in `res/layout/layout_native_custom.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <!-- Icon -->
        <ImageView
            android:id="@+id/ad_app_icon"
            android:layout_width="40dp"
            android:layout_height="40dp"/>

        <!-- Headline -->
        <TextView
            android:id="@+id/ad_headline"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="16sp"
            android:textStyle="bold"/>

        <!-- Body -->
        <TextView
            android:id="@+id/ad_body"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="14sp"/>

        <!-- Media View -->
        <com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
            android:id="@+id/ad_media"
            android:layout_width="match_parent"
            android:layout_height="200dp"/>

        <!-- Call to Action -->
        <Button
            android:id="@+id/ad_call_to_action"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"/>

    </LinearLayout>
</com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView>
```

Use custom layout:

```kotlin
SpaceNative.show(
    space = "ADMOB_Native_List",
    viewGroup = binding.nativeContainer,
    layoutRes = R.layout.layout_native_custom,
    callback = callback
)
```

## Jetpack Compose API

```kotlin
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import com.admob.adspace.native.SpaceNative
import com.admob.adspace.native.NativeCallback
import com.admob.adspace.native.NativeError
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView

@Composable
fun NativeAd(
    space: String,
    layoutRes: Int,
    modifier: Modifier = Modifier
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
            SpaceNative.showMedium(
                space = space,
                viewGroup = frameLayout,
                layoutRes = layoutRes,
                callback = object : NativeCallback {
                    override fun onLoaded(nativeAdView: NativeAdView, nativeAd: NativeAd, space: String) {}
                    override fun onFailed(space: String, error: NativeError) {}
                    override fun onImpression(space: String) {}
                    override fun onClicked(space: String) {}
                    override fun onPaid(space: String, revenue: NativeRevenue) {}
                }
            )
        }
    )

    DisposableEffect(space) {
        onDispose {
            SpaceNative.clearCache(space)
        }
    }
}

// Usage
@Composable
fun ContentScreen() {
    LazyColumn {
        items(10) { index ->
            if (index % 5 == 0) {
                NativeAd(
                    space = "ADMOB_Native_List",
                    layoutRes = R.layout.layout_native_medium
                )
            } else {
                ContentItem(index)
            }
        }
    }
}
```

## Advanced Features

### Preload Native Ad

```kotlin
SpaceNative.preload(
    space = "ADMOB_Native_List",
    layoutRes = R.layout.layout_native_medium,
    callback = object : PreloadCallback {
        override fun onPreloadSuccess() {
            // Ad preloaded
        }

        override fun onPreloadFailed(error: NativeError) {
            // Failed to preload
        }
    }
)
```

### Clear Cache

```kotlin
// Clear specific space
SpaceNative.clearCache("ADMOB_Native_List")

// Clear all native cache
SpaceNative.clearAllCache()
```

## Configuration

In `assets/ads_config.json`:

```json
{
  "space": "ADMOB_Native_List",
  "adsType": "native",
  "ids": [
    "ca-app-pub-3940256099942544/2247696110",
    "ca-app-pub-3940256099942544/1044960115"
  ],
  "enable": true,
  "minInterval": 30000,
  "adChoicesPosition": "top_right"
}
```

**adChoicesPosition options**: `top_left`, `top_right`, `bottom_left`, `bottom_right`

## Best Practices

1. **Use appropriate size** - Match ad size to content context
2. **Preload in lists** - Preload before scrolling to position
3. **Clear cache** - Always clear in onDestroy()
4. **Hide on failure** - Hide container if ad fails to load
5. **Custom layouts** - Create layouts matching your app design
6. **Respect min interval** - SDK enforces automatically
7. **RecyclerView integration** - Use ViewHolder pattern

## RecyclerView Integration

```kotlin
class ContentAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    companion object {
        const val VIEW_TYPE_CONTENT = 0
        const val VIEW_TYPE_AD = 1
        const val AD_FREQUENCY = 5 // Show ad every 5 items
    }

    override fun getItemViewType(position: Int): Int {
        return if (position % AD_FREQUENCY == 0) VIEW_TYPE_AD else VIEW_TYPE_CONTENT
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            VIEW_TYPE_AD -> AdViewHolder(/* inflate ad layout */)
            else -> ContentViewHolder(/* inflate content layout */)
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is AdViewHolder -> {
                SpaceNative.showMedium(
                    space = "ADMOB_Native_List",
                    viewGroup = holder.adContainer,
                    layoutRes = R.layout.layout_native_medium,
                    callback = holder.callback
                )
            }
            is ContentViewHolder -> {
                // Bind content
            }
        }
    }
}
```

## Common Issues

**Native ad not showing?**
- Check layout resource exists
- Verify all required views have correct IDs
- Check space is enabled in config
- Ensure container has proper height

**Layout issues?**
- Use NativeAdView as root element
- Set proper IDs for ad components
- Test with different ad sizes

**Memory leaks?**
- Always clear cache in onDestroy()
- Don't hold references to NativeAdView
- Use ViewHolder pattern in RecyclerView
