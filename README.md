# Flutter GPU Memory Pool Bug Reproduction

A minimal Flutter project that demonstrates the GPU memory pool exhaustion bug that occurs when apps return from background state on iOS devices.

## Problem Description

This project reproduces a critical issue where Flutter apps lose GPU access after being backgrounded on iOS devices, resulting in image rendering failures. The bug manifests as:

- **Normal Operation**: When the app is in foreground, all images load successfully
- **After Backgrounding**: When the app returns from background, only ~64 images can be successfully rendered
- **GPU Memory Pool Exhaustion**: Additional image rendering attempts fail due to GPU memory pool limitations

## Technical Details

### Root Cause

The issue is related to iOS GPU memory management and Flutter's interaction with the Metal rendering backend. When an app is backgrounded:

1. iOS may reclaim GPU memory resources
2. Flutter's GPU memory pool becomes limited
3. Subsequent image decoding/rendering operations fail when the pool is exhausted
4. The magic number appears to be around 64 successfully rendered images before failures occur

**Specific Technical Root Cause:**
The bug originates from Flutter's Impeller rendering engine, specifically in the context pool management:

- **Source Code**: [`context.h` line 61](https://github.com/flutter/flutter/blob/3.32.8/engine/src/flutter/impeller/renderer/context.h#L61)
- **Issue**: The GPU memory pool has a hardcoded limit that becomes problematic when iOS reclaims GPU resources during background transitions
- **Impact**: Once the pool is exhausted (~64 images), subsequent rendering operations fail silently

### Affected Flutter Versions

- **Critical**: This bug affects all Flutter versions **3.35 and below**
- **Status**: Issue persists across multiple Flutter stable releases
- **Impact**: Any Flutter app using image rendering on iOS is potentially affected

### Affected Components

- `CachedNetworkImage` widget
- Flutter's image decoding pipeline
- iOS Metal rendering backend
- GPU memory allocation system

## Demo Video

The following video demonstrates the GPU memory pool bug in action:

https://github.com/user-attachments/assets/d4b6df38-8a28-4fc3-a1f9-bdc0bb54f060

**Video Description:**

- **First part**: Shows normal operation with button-triggered image loading (all 100 images succeed)
- **Second part**: Shows the bug reproduction after app returns from background (only ~64 images succeed, rest fail)
- **Key observation**: Clear difference between foreground performance vs post-background performance

> **Note**: If the video doesn't display inline, you can [download and view it directly](./resources/demo.mp4)

## Fixed Version Demo

After applying the fix (using the patched `cached_network_image` package), the issue is resolved:

**To apply the fix:**

1. Open `pubspec.yaml`
2. Comment out the current `cached_network_image: ^3.4.1` line
3. Uncomment the git dependency block that points to the fixed version

**Fixed Version Video:**

https://github.com/user-attachments/assets/7c5f8534-e735-4b8e-821a-7b795a829e30

The fixed version demonstrates:

- ✅ All 100 images load successfully even after app returns from background
- ✅ Success count remains: 100, Failed count: 0
- ✅ No GPU memory pool exhaustion
- ✅ Consistent behavior between foreground and post-background states

**Fix Details:**

- **Repository**: https://github.com/mutant0113/flutter_cached_network_image
- **Branch**: `fix_ios_image_upload_failed_due_to_loss_of_GPU_access`
- **Commit**: `12ff326a66049e75521f4f2ac564281836be8aa5`
- **Changes**: Addresses the GPU context pool management issues in the cached network image implementation

## Reproduction Steps

1. **Setup**: Run the Flutter app on an iOS device or simulator
2. **Initial Test**: Tap "Start Loading 100 Images" button - observe all images load successfully
3. **Background the App**: Press home button or switch to another app
4. **Wait**: Leave the app in background for 10-30 seconds
5. **Return to App**: Switch back to the Flutter app
6. **Trigger Bug**: Tap "Start Loading 100 Images" again
7. **Observe Results**: Notice that only ~64 images load successfully, the rest fail

## Project Structure

```
lib/
  main.dart              # Main application with GPU bug reproduction
resources/
  demo.mp4              # Video demonstration of the issue
```

## Key Code Components

### ImageLoadTestPage

- Loads 100 `CachedNetworkImage` widgets simultaneously
- Tracks success/failure counts with `ValueNotifier`
- Automatically triggers reload when app returns from background
- Uses placeholder images from `placehold.co` service

### WrappedCachedNetworkImage

- Wraps `CachedNetworkImage` with success/failure callbacks
- Implements `WidgetsBindingObserver` for lifecycle management
- Provides error handling and logging

## Dependencies

```yaml
dependencies:
  cached_network_image: ^3.4.1  # For network image caching and display
  flutter: sdk: flutter
```

## Environment

- **Flutter SDK**: ^3.7.0 (reproduces the bug - affects all versions ≤3.35)
- **Target Platform**: iOS (bug specific to iOS)
- **Testing**: iPhone/iPad devices or iOS Simulator
- **Bug Status**: Confirmed in Flutter 3.35 and all previous versions

## Expected vs Actual Behavior

### Expected (Foreground)

- ✅ All 100 images load successfully
- ✅ Success count: 100, Failed count: 0

### Actual (After Background)

- ❌ Only ~64 images load successfully
- ❌ Success count: ~64, Failed count: ~36
- ❌ Error logs show GPU/rendering failures

## Related Issues

This bug is related to broader iOS GPU memory management issues in Flutter applications, particularly affecting:

- Image-heavy applications
- Apps with dynamic content loading
- Background/foreground transitions
- Memory-constrained devices

**Version Impact**: This is a widespread issue affecting Flutter 3.35 and all earlier versions, making it a critical concern for production iOS applications using Flutter.

### Flutter Engine Issues & Pull Requests

The Flutter team is actively working on this issue. Related GitHub issues and pull requests:

- **[Pull Request #164036](https://github.com/flutter/flutter/pull/164036)** - Initial fix attempt for GPU memory pool management
- **[Pull Request #166876](https://github.com/flutter/flutter/pull/166876)** - Additional improvements and refinements to GPU context handling

These PRs address the underlying Impeller engine issues that cause GPU memory pool exhaustion during background/foreground transitions on iOS devices.

## Workarounds

Currently investigating potential workarounds:

- Image preloading strategies
- GPU memory pool management
- Background task handling
- Manual memory cleanup

## Running the Project

```bash
# Get dependencies
flutter pub get

# Run on iOS device/simulator
flutter run -d ios

# Or run on specific device
flutter devices
flutter run -d [device-id]
```

## Contributing

This is a minimal reproduction case for debugging purposes. If you have insights into the GPU memory pool issue or potential fixes, please contribute to the investigation.
