# Rewarded Interstitial Ads Integration

Rewarded interstitial ads are full-screen ads that give users rewards for watching.

## Package Imports

```kotlin
import com.admob.adspace.rewardedinterstitial.SpaceRewardedInterstitial
import com.admob.adspace.rewardedinterstitial.RewardedInterstitialCallback
import com.admob.adspace.rewardedinterstitial.RewardedInterstitialError
```

## Basic Implementation

```kotlin
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.admob.adspace.rewardedinterstitial.SpaceRewardedInterstitial
import com.admob.adspace.rewardedinterstitial.RewardedInterstitialCallback
import com.admob.adspace.rewardedinterstitial.RewardedInterstitialError

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Preload rewarded interstitial
        preloadRewardedInterstitial()

        binding.btnShowAd.setOnClickListener {
            showRewardedInterstitial()
        }
    }

    private fun preloadRewardedInterstitial() {
        SpaceRewardedInterstitial.preload(
            space = "ADMOB_RewardedInterstitial_General",
            forceRefresh = false,
            callback = object : RewardedInterstitialCallback {
                override fun onLoaded(space: String) {
                    // Ad loaded
                }

                override fun onFailed(space: String, error: RewardedInterstitialError) {
                    // Failed to load
                }

                override fun onShowed(space: String) {
                    // Ad displayed
                }

                override fun onDismissed(space: String) {
                    // Preload next ad
                    preloadRewardedInterstitial()
                }

                override fun onEarnedReward(space: String, type: String, amount: Int) {
                    // Give reward to user
                    giveUserReward(type, amount)
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

    private fun showRewardedInterstitial() {
        SpaceRewardedInterstitial.show(
            space = "ADMOB_RewardedInterstitial_General",
            activity = this,
            forceShow = false,
            loadIfNotAvailable = true,
            showLoading = true,
            callback = object : RewardedInterstitialCallback {
                override fun onLoaded(space: String) {}
                override fun onFailed(space: String, error: RewardedInterstitialError) {}
                override fun onShowed(space: String) {}
                override fun onDismissed(space: String) {}
                override fun onEarnedReward(space: String, type: String, amount: Int) {
                    giveUserReward(type, amount)
                }
                override fun onClicked(space: String) {}
                override fun onImpression(space: String) {}
                override fun onPaid(space: String, revenue: AdRevenue) {}
            }
        )
    }

    private fun giveUserReward(type: String, amount: Int) {
        // Implement reward logic
    }
}
```

## Configuration

In `assets/ads_config.json`:

```json
{
  "space": "ADMOB_RewardedInterstitial_General",
  "adsType": "reward_inter",
  "ids": [
    "ca-app-pub-3940256099942544/5354046379"
  ],
  "enable": true,
  "minInterval": 60000,
  "mute": false
}
```

## Difference from Rewarded Ads

**Rewarded Interstitial** vs **Rewarded**:
- Rewarded Interstitial: Full-screen, can be skipped after a few seconds
- Rewarded: Must watch entire video to get reward

Use rewarded interstitial when you want to give users the option to skip but still earn a reward.

## Best Practices

Same as Rewarded Ads - see [rewarded.md](rewarded.md) for detailed best practices.
