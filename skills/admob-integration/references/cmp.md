# CMP Consent Management

CMP (Consent Management Platform) integration using Google UMP SDK.

## Package Imports

```kotlin
import com.admob.adspace.cmp.CMPManager
```

## Overview

AdSpaceSDK integrates Google's User Messaging Platform (UMP) for GDPR/privacy consent management. CMP consent is required before showing ads in regions with privacy regulations.

## Automatic CMP Flow

By default, SDK handles CMP automatically:

1. SDK initializes on app start
2. On first Activity resume, CMP consent form shows (if required)
3. After consent obtained, AdMob SDK initializes
4. Ads can now be requested

## Configuration

### Enable Auto CMP

In `assets/ads_config.json`:

```json
{
  "ads": {
    "global": {
      "enable": true,
      "cmp_auto": true,
      "min_interval": 30000
    }
  }
}
```

**cmp_auto options**:
- `true` - SDK automatically shows consent form on first resume
- `false` - Manual consent management required

## Manual CMP Management

### Check Consent Status

```kotlin
import com.admob.adspace.AdSpaceSDK

val cmpManager = AdSpaceSDK.getCMPManager()

// Check if consent is required
if (cmpManager.isConsentRequired()) {
    // Show consent form
}

// Check if consent obtained
if (cmpManager.canRequestAds()) {
    // Can show ads
}
```

### Request Consent Manually

```kotlin
import android.app.Activity
import com.admob.adspace.AdSpaceSDK

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val cmpManager = AdSpaceSDK.getCMPManager()

        cmpManager.requestConsent(
            activity = this,
            onConsentGathered = {
                // Consent obtained, can show ads
                initializeAds()
            },
            onConsentError = { error ->
                // Handle error
            }
        )
    }
}
```

## Testing CMP

### Test with Debug Geography

```kotlin
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentRequestParameters

// In debug builds, force EEA geography
val debugSettings = ConsentDebugSettings.Builder(context)
    .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
    .addTestDeviceHashedId("YOUR_TEST_DEVICE_ID")
    .build()

val params = ConsentRequestParameters.Builder()
    .setConsentDebugSettings(debugSettings)
    .build()
```

### Reset Consent (Testing Only)

```kotlin
import com.google.android.ump.UserMessagingPlatform

// Reset consent for testing
UserMessagingPlatform.getConsentInformation(context)
    .reset()
```

## CMP Flow Diagram

```
App Start
    ↓
AdSpaceSDK.initialize()
    ↓
ConfigManager loads config
    ↓
CMPManager.initialize()
    ↓
Activity.onResume() (first time)
    ↓
cmp_auto = true?
    ├─ YES → CMPManager.requestConsent()
    │         ↓
    │    Show consent form to user
    │         ↓
    │    User accepts/rejects
    │         ↓
    │    AdMobManager.initialize()
    │         ↓
    │    Ads can be requested
    │
    └─ NO → AdMobManager.initialize() immediately
             ↓
        Ads can be requested
```

## Best Practices

1. **Use auto CMP** - Let SDK handle consent flow
2. **Test in EEA** - Use debug geography for testing
3. **Handle errors** - Provide fallback if consent fails
4. **Don't block app** - App should work without ads if consent denied
5. **Respect user choice** - Don't repeatedly ask for consent

## Common Patterns

### Show Privacy Settings

```kotlin
import com.admob.adspace.AdSpaceSDK

class SettingsActivity : AppCompatActivity() {

    private fun showPrivacySettings() {
        val cmpManager = AdSpaceSDK.getCMPManager()

        // Show privacy options form
        cmpManager.showPrivacyOptionsForm(
            activity = this,
            onFormDismissed = { error ->
                if (error != null) {
                    // Handle error
                } else {
                    // Form dismissed successfully
                }
            }
        )
    }
}
```

### Check Before Showing Ads

```kotlin
private fun showAd() {
    val cmpManager = AdSpaceSDK.getCMPManager()

    if (!cmpManager.canRequestAds()) {
        // Cannot show ads - consent not obtained
        return
    }

    // Show ad
    SpaceInterstitial.show(...)
}
```

## Remote Config Control

Control CMP behavior remotely via Firebase Remote Config:

```
ads.global.cmp_auto = false
```

This disables automatic CMP flow without app update.

## Common Issues

**Consent form not showing?**
- Check `cmp_auto` is `true` in config
- Verify user is in region requiring consent
- Check test device ID is correct (for testing)

**Ads not showing after consent?**
- Check `canRequestAds()` returns `true`
- Verify AdMob SDK initialized after consent
- Check ad space is enabled in config

**Form shows every time?**
- Consent should persist across sessions
- Check UMP SDK is properly configured
- Verify app has storage permissions
