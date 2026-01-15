# cool-retro-term for macOS (Apple Silicon & Intel)

This repository provides a Homebrew Tap to easily install [cool-retro-term](https://github.com/Swordfish90/cool-retro-term) on macOS. It specifically fixes build issues on Apple Silicon (M1/M2/M3) and includes patches for better compatibility (e.g., Braille character support for `btop`).

## Installation

First, add this custom tap to Homebrew:

```bash
brew tap buchio/cool-retro-term-build https://github.com/buchio/cool-retro-term-build
```

### Option 1: Install Binary (Recommended)
Install the pre-built application using Homebrew Cask. This is the fastest method.

```bash
brew install --cask cool-retro-term
```
*Note: This downloads the dmg from the Releases page of this repository.*

### Option 2: Build from Source
If you prefer to compile from source or there is no pre-built binary for your architecture/version:

```bash
brew install cool-retro-term
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
    ./homebrew/build-macos.sh
    ```
    *This will create a `cool-retro-term.dmg` and `cool-retro-term.app` in the directory.*

## Features & Patches

- **Apple Silicon Support**: Automatically handles Qt5 path issues and architecture specific configurations.
- **Braille Support**: Patches `konsole_wcwidth.cpp` to correct the width of Braille characters (U+2800-U+28FF). This fixes display glitches in tools like `btop` and `htop`.