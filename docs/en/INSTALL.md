# Installation and Build

## Requirements

- macOS 26 or later
- Xcode 27.0
- Swift 6.4 compiler
- Apple Silicon Mac recommended

## Build locally

1. Clone the repository:

```bash
git clone https://github.com/skurrry/NotchShelf.git
cd NotchShelf
```

2. Open `NotchShelf.xcodeproj`.
3. Select the `NotchShelf` target.
4. Open **Signing & Capabilities**.
5. Choose your own Development Team.
6. Set a unique Bundle Identifier, for example `com.yourname.NotchShelf`.
7. Select **My Mac** as the destination.
8. Run **Product → Clean Build Folder**.
9. Build with `⌘B` and run with `⌘R`.

## Native frameworks

The project uses native Apple frameworks. If linking is not resolved automatically, verify these entries under **Frameworks, Libraries, and Embedded Content** with **Do Not Embed**:

- QuickLookUI.framework
- QuickLookThumbnailing.framework
- CoreWLAN.framework
- IOKit.framework
- SystemConfiguration.framework

## Troubleshooting

- Make sure every Swift file appears only once in **Build Phases → Compile Sources**.
- Delete project-specific Derived Data after major project-file changes.
- Do not commit personal signing certificates, provisioning profiles, or `xcuserdata`.
