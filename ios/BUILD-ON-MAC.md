# Build on Mac

The project was authored on a Linux machine, so it ships as an **XcodeGen**
spec — you generate the real `.xcodeproj` on your Mac in under five minutes.

## One-time setup

1. **Install Xcode** from the Mac App Store (or
   [developer.apple.com](https://developer.apple.com/download/)). Open it once
   so it finishes installing its tools.
2. **Install XcodeGen**:
   ```sh
   brew install xcodegen
   ```
   (No Homebrew? Install it from [brew.sh](https://brew.sh) first.)

## Every build

```sh
cd /path/to/Fun-Learning/ios     # wherever you cloned the repo
xcodegen generate                # creates FunLearning.xcodeproj
open FunLearning.xcodeproj
```

In Xcode:

1. Select the **FunLearning** target → **Signing & Capabilities**.
2. Pick your **Team** (free Apple ID works — see below).
3. Change the **Bundle Identifier** if Xcode complains it is taken
   (default: `com.funlearning.app`).
4. Plug in the iPhone via USB, select it as the run destination, press **▶**.

## Signing notes

- A **free Apple ID** runs the app on your own iPhone (re-sign weekly in
  Xcode: it prompts you).
- A paid **Apple Developer Program** membership ($99/yr) is only needed later
  for TestFlight / App Store distribution.

## Troubleshooting

- `xcodegen: command not found` → re-run `brew install xcodegen`, then
  `brew doctor`.
- Red "Signing" errors → pick a Team and/or change the bundle ID suffix.
- No sound in simulator → test on a real iPhone; the simulator's audio
  session behavior differs.
