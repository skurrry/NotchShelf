# NotchShelf

> A native macOS utility that turns the MacBook notch into a smart workspace centered around a persistent file shelf.

[Deutsch](docs/de/README.md) · **English**

![Status](https://img.shields.io/badge/status-alpha-orange)
![macOS](https://img.shields.io/badge/macOS-26%2B-black)
![Swift](https://img.shields.io/badge/Swift-6.4-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

## About

NotchShelf transforms the MacBook notch into an expandable native workspace. Its core feature is a persistent file shelf for temporarily storing, previewing, and dragging files between apps. The project is designed to grow with additional everyday tools while keeping the shelf at its center.

## Current features

- Persistent file shelf integrated into the MacBook notch
- Native Quick Look thumbnails for images, PDFs, videos, and other supported files
- Drag files into the shelf and drag them back to Finder, Desktop, or other apps
- Quick Look preview by double-click or preview button
- Smart compact bar with date, time, battery, file, and break information
- Configurable timer with multiple visual styles and alarm actions
- Liquid Glass appearance and top-down opening animations
- Local-only file storage in Application Support

## Project status

NotchShelf is currently **alpha software**. Features, architecture, and user interface may change. The current project builds successfully, but public testing is still limited.

## Requirements

- macOS 26 or later
- Tested on macOS 27.0.1
- Xcode 27.0
- Swift 6.4 compiler
- A MacBook with a display notch is recommended

## Build and installation

See the full [English installation guide](docs/en/INSTALL.md) or the [German installation guide](docs/de/INSTALL.md).

Quick start:

1. Clone or download the repository.
2. Open `NotchShelf.xcodeproj` in Xcode.
3. Select the `NotchShelf` target.
4. Choose your own Development Team under **Signing & Capabilities**.
5. Set a unique Bundle Identifier if required.
6. Select **My Mac** and run the project with `⌘R`.

## Screenshots

Add public screenshots to:

```text
Docs/Screenshots/
```

Recommended screenshots:

- Compact smart bar
- File shelf with Quick Look thumbnails
- Timer dashboard
- Alarm view
- Settings window

## Documentation

- [Installation and build guide](docs/en/INSTALL.md)
- [Roadmap](docs/en/ROADMAP.md)
- [Contributing](docs/en/CONTRIBUTING.md)
- [Security policy](docs/en/SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## Contributing

Issues and pull requests are welcome. Please read [CONTRIBUTING.md](docs/en/CONTRIBUTING.md) before submitting changes.

## License

NotchShelf is available under the [MIT License](LICENSE).

## Apple disclaimer

NotchShelf is an independent open-source project and is not affiliated with or endorsed by Apple Inc. Apple, macOS, MacBook, Xcode, and Quick Look are trademarks of their respective owners.
