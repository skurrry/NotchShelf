# NotchShelf

> Eine native macOS-App, die die MacBook-Notch in einen intelligenten Arbeitsbereich rund um einen persistenten Dateischrank verwandelt.

**Deutsch** · [English](../../README.md)

## Über das Projekt

NotchShelf verwandelt die MacBook-Notch in einen erweiterbaren nativen Arbeitsbereich. Die Kernfunktion ist ein persistenter Dateischrank, in dem Dateien temporär abgelegt, als Vorschau angezeigt und zwischen Apps verschoben werden können. Das Projekt soll zukünftig um weitere alltägliche Werkzeuge wachsen, während das Shelf im Mittelpunkt bleibt.

## Aktuelle Funktionen

- Persistenter Dateischrank direkt in der MacBook-Notch
- Native Quick-Look-Vorschauen für Bilder, PDFs, Videos und weitere unterstützte Dateien
- Dateien in das Shelf hineinziehen und wieder zu Finder, Desktop oder anderen Apps herausziehen
- Quick-Look-Vorschau per Doppelklick oder Vorschau-Button
- Intelligente Compact-Leiste mit Datum, Uhrzeit, Batterie-, Datei- und Pauseninformationen
- Konfigurierbarer Timer mit mehreren Darstellungen und Alarmaktionen
- Liquid-Glass-Darstellung und Öffnungsanimationen von oben nach unten
- Ausschließlich lokale Dateispeicherung in Application Support

## Projektstatus

NotchShelf befindet sich aktuell in der **Alpha-Phase**. Funktionen, Architektur und Benutzeroberfläche können sich ändern. Das Projekt kompiliert, wurde öffentlich aber noch nicht umfassend getestet.

## Voraussetzungen

- macOS 26 oder neuer
- Getestet unter macOS 27.0.1
- Xcode 27.0
- Swift-6.4-Compiler
- Ein MacBook mit Display-Notch wird empfohlen

## Installation und Build

Siehe die vollständige [deutsche Installationsanleitung](INSTALL.md).

Kurzfassung:

1. Repository klonen oder herunterladen.
2. `NotchShelf.xcodeproj` in Xcode öffnen.
3. Das Target `NotchShelf` auswählen.
4. Unter **Signing & Capabilities** das eigene Development Team auswählen.
5. Falls nötig eine eindeutige Bundle-ID festlegen.
6. **My Mac** auswählen und mit `⌘R` starten.

## Dokumentation

- [Installation und Build](INSTALL.md)
- [Roadmap](ROADMAP.md)
- [Beitragsrichtlinien](CONTRIBUTING.md)
- [Sicherheitsrichtlinie](SECURITY.md)
- [Verhaltenskodex](../../CODE_OF_CONDUCT.md)

## Lizenz

NotchShelf wird unter der [MIT-Lizenz](../../LICENSE) veröffentlicht.

## Apple-Hinweis

NotchShelf ist ein unabhängiges Open-Source-Projekt und steht in keiner Verbindung zu Apple Inc. Apple, macOS, MacBook, Xcode und Quick Look sind Marken ihrer jeweiligen Inhaber.
