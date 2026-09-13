# Android installation diagnostics

Current physical-device validation target: Android 13.

The release APK builds successfully in CI, but physical installation currently returns the generic Android message "App not installed".

Before changing application functionality, verify the generated APK with Android SDK tools and produce ABI-specific release APKs for installation testing.

Required checks for the next Android build:
- apksigner verify --verbose --print-certs
- aapt dump badging
- build ABI-specific APKs with flutter build apk --release --split-per-abi
- upload all generated APKs as CI artifacts

This file documents the installation-validation gate and does not change application runtime behavior.
