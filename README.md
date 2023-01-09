<img src="https://og.sznm.dev/api/generate?heading=muvees_flutter&text=TMDB%20flutter%20app&template=color&center=true&height=320" />

powered by:

- **go_router**
- riverpod
- **dio_cache_interceptor**
- cached_network_image

## Demo

| Preview |
|---|
| https://user-images.githubusercontent.com/17046154/211236202-305e8b48-0d55-4165-82b2-1bae35cef0e4.mp4 |



## Commands

1. build_runner: `fvm flutter pub run build_runner build --delete-conflicting-outputs`

### Build Signed Android App (without Play Store)

1. Make sure keystore and its properties file is available at the `/android` folder
2. Then build the app using this command: `fvm flutter build apk --release --split-per-abi`

## References

- Libs
  - https://pub.dev/packages/dio
  - https://pub.dev/packages/retrofit
  - https://docs-v2.riverpod.dev/
  - https://pub.dev/packages/loggy
  - https://pub.dev/packages/envied
- https://codewithandrea.com/articles/flutter-api-keys-dart-define-env-files/
- https://app.quicktype.io/
- https://stackoverflow.com/questions/56824557/what-is-the-difference-between-armeabi-v7a-arm64-v8a-x86
