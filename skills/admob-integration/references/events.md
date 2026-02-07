# Event Handling

AdSpaceSDK provides a global event system for tracking ad lifecycle events.

## Package Imports

```kotlin
import com.admob.adspace.AdSpaceSDK
import com.admob.adspace.core.event.AdEventListener
import com.admob.adspace.core.event.AdEvent
```

## Event Types

AdSpaceSDK emits events for all ad lifecycle stages:

- `AdEvent.Loaded` - Ad loaded successfully
- `AdEvent.Failed` - Ad failed to load
- `AdEvent.Showed` - Ad displayed to user
- `AdEvent.Dismissed` - Ad dismissed by user
- `AdEvent.Clicked` - Ad clicked
- `AdEvent.Impression` - Ad impression recorded
- `AdEvent.Paid` - Ad revenue received
- `AdEvent.EarnedReward` - User earned reward (rewarded ads only)

## Global Event Listener

Register a global listener to receive all ad events:

```kotlin
import android.app.Application
import com.admob.adspace.AdSpaceSDK
import com.admob.adspace.core.event.AdEventListener
import com.admob.adspace.core.event.AdEvent

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize SDK
        AdSpaceSDK.initialize(this, config)

        // Register global event listener
        AdSpaceSDK.setGlobalAdCallback(object : AdEventListener {
            override fun onAdEvent(event: AdEvent) {
                when (event) {
                    is AdEvent.Loaded -> {
                        logEvent("Ad Loaded", event.space, event.adsType)
                    }
                    is AdEvent.Failed -> {
                        logEvent("Ad Failed", event.space, event.adsType, event.error)
                    }
                    is AdEvent.Showed -> {
                        logEvent("Ad Showed", event.space, event.adsType)
                    }
                    is AdEvent.Dismissed -> {
                        logEvent("Ad Dismissed", event.space, event.adsType)
                    }
                    is AdEvent.Clicked -> {
                        logEvent("Ad Clicked", event.space, event.adsType)
                    }
                    is AdEvent.Impression -> {
                        logEvent("Ad Impression", event.space, event.adsType)
                    }
                    is AdEvent.Paid -> {
                        logRevenue(event.space, event.adsType, event.revenue)
                    }
                    is AdEvent.EarnedReward -> {
                        logReward(event.space, event.type, event.amount)
                    }
                }
            }
        })
    }

    private fun logEvent(eventName: String, space: String, adsType: String, error: String? = null) {
        // Send to analytics
        analytics.logEvent(eventName, mapOf(
            "space" to space,
            "ads_type" to adsType,
            "error" to error
        ))
    }

    private fun logRevenue(space: String, adsType: String, revenue: AdRevenue) {
        // Send to analytics
        analytics.logRevenue(
            value = revenue.value,
            currency = revenue.currencyCode,
            space = space,
            adsType = adsType
        )
    }
}
```

## Per-Space Event Listener

Register listener for specific ad space:

```kotlin
import com.admob.adspace.AdSpaceSDK

val eventBus = AdSpaceSDK.getEventBus()

eventBus.subscribe("ADMOB_Interstitial_General", object : AdEventListener {
    override fun onAdEvent(event: AdEvent) {
        // Handle events for this space only
    }
})
```

## Common Patterns

### Analytics Integration

```kotlin
class AnalyticsManager {

    fun setupAdEventTracking() {
        AdSpaceSDK.setGlobalAdCallback(object : AdEventListener {
            override fun onAdEvent(event: AdEvent) {
                when (event) {
                    is AdEvent.Impression -> {
                        // Track impression
                        FirebaseAnalytics.getInstance(context).logEvent("ad_impression", Bundle().apply {
                            putString("ad_space", event.space)
                            putString("ad_type", event.adsType)
                        })
                    }
                    is AdEvent.Clicked -> {
                        // Track click
                        FirebaseAnalytics.getInstance(context).logEvent("ad_click", Bundle().apply {
                            putString("ad_space", event.space)
                            putString("ad_type", event.adsType)
                        })
                    }
                    is AdEvent.Paid -> {
                        // Track revenue
                        FirebaseAnalytics.getInstance(context).logEvent("ad_revenue", Bundle().apply {
                            putString("ad_space", event.space)
                            putString("ad_type", event.adsType)
                            putDouble("value", event.revenue.value)
                            putString("currency", event.revenue.currencyCode)
                        })
                    }
                    else -> {}
                }
            }
        })
    }
}
```

### Revenue Tracking

```kotlin
class RevenueTracker {

    private var totalRevenue = 0.0

    init {
        AdSpaceSDK.setGlobalAdCallback(object : AdEventListener {
            override fun onAdEvent(event: AdEvent) {
                if (event is AdEvent.Paid) {
                    totalRevenue += event.revenue.value

                    // Send to backend
                    api.trackRevenue(
                        space = event.space,
                        adsType = event.adsType,
                        value = event.revenue.value,
                        currency = event.revenue.currencyCode
                    )
                }
            }
        })
    }

    fun getTotalRevenue(): Double = totalRevenue
}
```

### Error Monitoring

```kotlin
class AdErrorMonitor {

    init {
        AdSpaceSDK.setGlobalAdCallback(object : AdEventListener {
            override fun onAdEvent(event: AdEvent) {
                if (event is AdEvent.Failed) {
                    // Log to crash reporting
                    Crashlytics.getInstance().log("Ad Failed: ${event.space} - ${event.error}")

                    // Track error rate
                    analytics.logEvent("ad_error", mapOf(
                        "space" to event.space,
                        "ads_type" to event.adsType,
                        "error" to event.error
                    ))
                }
            }
        })
    }
}
```

## Unsubscribe from Events

```kotlin
// Remove global listener
AdSpaceSDK.setGlobalAdCallback(null)

// Unsubscribe from specific space
val eventBus = AdSpaceSDK.getEventBus()
eventBus.unsubscribe("ADMOB_Interstitial_General", listener)
```

## Best Practices

1. **Use global listener for analytics** - Track all ad events centrally
2. **Per-space listeners for specific logic** - Use when needed for specific spaces
3. **Don't block event handlers** - Keep handlers fast and non-blocking
4. **Unsubscribe when done** - Prevent memory leaks
5. **Log revenue events** - Track ad revenue for optimization

## Common Issues

**Events not firing?**
- Check listener is registered before ads load
- Verify SDK is initialized
- Check listener is not null

**Memory leaks?**
- Always unsubscribe listeners when done
- Use weak references if needed
- Don't hold Activity references in listeners
