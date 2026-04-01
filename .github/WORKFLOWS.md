# GitHub Actions Setup

## Overview

This project uses GitHub Actions for CI/CD automation.

## Workflows

### 1. CI (`ci.yaml`)

**Triggers:** Push to `main` branch, Pull Requests to `main`

**Jobs:**
- **Analyze & Build**
  - Setup FVM (Flutter Version Management)
  - Run `flutter pub get`
  - Run `build_runner` for code generation
  - Run `flutter analyze` for linting
  - Build debug APK
  - Upload APK as artifact (PR only, 14 days retention)

**Outputs:**
- Debug APK available in PR checks
- Analysis results in GitHub Actions tab

---

### 2. Build Release APK (`build-apk.yaml`)

**Triggers:** Git tag push (e.g., `v1.2.1`)

**Jobs:**
- **Build Release**
  - Setup FVM, Java 17, Android SDK
  - Decode keystore from secrets
  - Run code generation
  - Build release APK
  - Upload to GitHub Release

**Required Secrets:**

| Secret | Description | Required For |
|--------|-------------|--------------|
| `KEYSTORE_BASE64` | Base64-encoded keystore file (.jks) | Release builds |
| `KEYSTORE_PASSWORD` | Keystore password | Release builds |
| `KEY_ALIAS` | Key alias name | Release builds |
| `KEY_PASSWORD` | Key password | Release builds |
| `TMDB_API_KEY` | TMDB API key | Release builds |

---

## Setup Instructions

### 1. Prepare Keystore

```bash
# Encode your keystore to base64
base64 -w 0 android/app/key.jks | pbcopy  # macOS
# or
base64 -w 0 android/app/key.jks | xclip -selection clipboard  # Linux
```

### 2. Add GitHub Secrets

Go to **Repository Settings → Secrets and variables → Actions** and add:

```
KEYSTORE_BASE64=<paste base64 string>
KEYSTORE_PASSWORD=<your keystore password>
KEY_ALIAS=<your key alias>
KEY_PASSWORD=<your key password>
TMDB_API_KEY=<your TMDB API key>
```

### 3. Verify Workflow

- Push to a feature branch → CI workflow runs
- Create PR → CI workflow runs, APK artifact uploaded
- Tag release (`git tag v1.2.1 && git push origin v1.2.1`) → Release workflow runs

---

## Local Testing

Test the CI workflow locally:

```bash
# Simulate CI steps
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter analyze
fvm flutter build apk --debug
```

---

## Artifacts

- **Debug APK:** Available in PR checks for 14 days
- **Release APK:** Attached to GitHub Release for 30 days

Download from: **Actions → Workflow run → Artifacts**

---

## Troubleshooting

### Build Fails on CI

1. Check `flutter analyze` passes locally
2. Ensure `build_runner` generates code without errors
3. Verify all secrets are correctly set

### Keystore Issues

```
Error: Keystore file not found
```

**Solution:** Ensure `KEYSTORE_BASE64` secret is set correctly (no line breaks)

### Code Generation Fails

```
Error: Missing dependencies in build_runner
```

**Solution:** Run `fvm dart run build_runner build --delete-conflicting-outputs` locally first

---

## Workflow Files

- `.github/workflows/ci.yaml` - CI on push/PR
- `.github/workflows/build-apk.yaml` - Release APK on tag
- `.github/workflows/release-please.yml` - Automated changelog (existing)
- `.github/workflows/release.yml` - GitHub release (existing)

---

## References

- [FVM Action](https://github.com/marketplace/actions/fvm-action)
- [Setup Java Action](https://github.com/marketplace/actions/setup-java-jdk)
- [Upload Artifact Action](https://github.com/marketplace/actions/upload-a-build-artifact)
- [Create GitHub Release Action](https://github.com/marketplace/actions/gh-release)
