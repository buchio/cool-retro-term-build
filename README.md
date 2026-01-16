# cool-retro-term for macOS (Apple Silicon)

This repository provides a Homebrew Tap to easily install [cool-retro-term](https://github.com/Swordfish90/cool-retro-term) on macOS. It specifically fixes build issues on Apple Silicon (M1/M2/M3).

## Installation

First, add this custom tap to Homebrew:

```bash
brew tap buchio/cool-retro-term-build https://github.com/buchio/cool-retro-term-build
```

### Option 1: Install Binary (Recommended)
Install the pre-built application using Homebrew Cask. This is the fastest method.

```bash
brew install --cask buchio/cool-retro-term-build/cool-retro-term
```
*Note: This downloads the dmg from the Releases page of this repository.*

### Option 2: Build from Source
If you prefer to compile from source or there is no pre-built binary for your architecture/version:

```bash
brew install buchio/cool-retro-term-build/cool-retro-term
```
*Note: This will take a few minutes as it downloads the source code and compiles it locally.*

## Manual Build

You can also build the application manually using the provided script without Homebrew.

1.  Clone this repository:
    ```bash
    git clone https://github.com/buchio/cool-retro-term-build.git
    cd cool-retro-term-build
    ```

2.  Run the build script:
    ```bash
    ./Formula/build-macos.sh
    ```
    *This will create a `cool-retro-term.dmg` and `cool-retro-term.app` in the directory.*

## Security & Privacy (Unidentified Developer Warning)

Since this application is built via a community script and is not signed with a paid Apple Developer Certificate, macOS may prevent it from opening by default with a warning that it is from an **"Unidentified Developer"**.

To open the app:

1.  **Right-click (or Control-click)** the `cool-retro-term` application in your `Applications` folder.
2.  Select **Open** from the context menu.
3.  Click **Open** in the dialog box that appears.

This only needs to be done once. Alternatively, you can go to **System Settings > Privacy & Security** and allow the app to run.

## Features

- **Apple Silicon Support**: Automatically handles Qt5 path issues and architecture specific configurations.
