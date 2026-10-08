# Installation und Build

## Voraussetzungen

- macOS 26 oder neuer
- Xcode 27.0
- Swift-6.4-Compiler
- Apple-Silicon-Mac empfohlen

## Lokal bauen

1. Repository klonen:

```bash
git clone https://github.com/skurrry/NotchShelf.git
cd NotchShelf
```

2. `NotchShelf.xcodeproj` öffnen.
3. Das Target `NotchShelf` auswählen.
4. **Signing & Capabilities** öffnen.
5. Das eigene Development Team auswählen.
6. Eine eindeutige Bundle-ID festlegen, zum Beispiel `com.deinname.NotchShelf`.
7. **My Mac** als Ziel auswählen.
8. **Product → Clean Build Folder** ausführen.
9. Mit `⌘B` bauen und mit `⌘R` starten.

## Native Frameworks

Falls Xcode die Verknüpfung nicht automatisch auflöst, unter **Frameworks, Libraries, and Embedded Content** mit **Do Not Embed** prüfen:

- QuickLookUI.framework
- QuickLookThumbnailing.framework
- CoreWLAN.framework
- IOKit.framework
- SystemConfiguration.framework

## Fehlerbehebung

- Jede Swift-Datei darf unter **Build Phases → Compile Sources** nur einmal vorkommen.
- Nach größeren Änderungen an der Projektdatei die projektspezifischen Derived Data löschen.
- Persönliche Zertifikate, Provisioning Profiles und `xcuserdata` nicht committen.
