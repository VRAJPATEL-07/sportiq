# Firebase Setup

This project uses Firebase. Follow these steps to generate `lib/firebase_options.dart` and configure platform apps locally.

1. Install the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

2. Ensure the pub cache bin is on your PATH (Windows):

```powershell
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
```

3. From the project root run the configure command (replace `--project` with your Firebase project id if needed):

```bash
flutterfire configure --project=sportiq-824eb --out=lib/firebase_options.dart --platforms=android,ios,web,windows
```

4. The CLI will register platform apps and write `lib/firebase_options.dart`. Commit that file to the repo if you want other developers to use the same configuration.

5. Add platform-specific files when required by Firebase features:
- Android: place `google-services.json` into `android/app/`
- iOS/macOS: place `GoogleService-Info.plist` into `ios/Runner/` and `macos/Runner/`

6. Google Sign-In setup (if using Google auth):
- Create OAuth 2.0 credentials in Google Cloud Console
- Add your Web client ID to the Firebase Console Authentication providers
- For Android/iOS/Windows follow the platform-specific steps in the Firebase Console

Notes:
- If you prefer to keep `lib/firebase_options.dart` out of source control, re-add it to `.gitignore`.
- If `flutterfire configure` requires interactive auth, run it locally where you can authorize the CLI in the browser.
