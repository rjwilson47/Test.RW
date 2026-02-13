/**
 * Capacitor Bridge - Native iOS integration
 * Handles status bar, splash screen, and haptic feedback
 */

import { Capacitor } from '@capacitor/core';

let StatusBar, SplashScreen, Haptics, ImpactStyle;

async function initNative() {
  if (!Capacitor.isNativePlatform()) return;

  try {
    const statusBarModule = await import('@capacitor/status-bar');
    StatusBar = statusBarModule.StatusBar;
    const splashModule = await import('@capacitor/splash-screen');
    SplashScreen = splashModule.SplashScreen;
    const hapticsModule = await import('@capacitor/haptics');
    Haptics = hapticsModule.Haptics;
    ImpactStyle = hapticsModule.ImpactStyle;
  } catch (e) {
    // Plugins not available - running in browser
    return;
  }

  // Configure status bar for iOS
  if (StatusBar) {
    try {
      await StatusBar.setStyle({ style: 'LIGHT' });
      await StatusBar.setBackgroundColor({ color: '#1a5632' });
    } catch (e) {
      // Some methods not available on all platforms
    }
  }

  // Hide native splash once web app splash is showing
  if (SplashScreen) {
    try {
      await SplashScreen.hide({ fadeOutDuration: 300 });
    } catch (e) {
      // Splash screen may have already been hidden
    }
  }

  // Add haptic feedback to interactive elements
  if (Haptics) {
    document.addEventListener('click', function (e) {
      var target = e.target.closest('button, .feature-card, .walk-card, .nav-item, .wildlife-header, .activity-card');
      if (target) {
        try {
          Haptics.impact({ style: ImpactStyle.Light });
        } catch (e) {
          // Haptics not available
        }
      }
    });
  }

  // Mark body as running in native context
  document.body.classList.add('native-ios');
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initNative);
} else {
  initNative();
}
