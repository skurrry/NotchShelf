# Zu NotchShelf beitragen

Issues und Pull Requests sind willkommen.

## Issues

Prüfe vor dem Erstellen, ob bereits ein ähnlicher Bericht existiert. Ein Fehlerbericht sollte enthalten:

- macOS-Version
- Xcode-Version bei Build-Problemen
- Schritte zur Reproduktion
- erwartetes Verhalten
- tatsächliches Verhalten
- bei Bedarf Screenshots oder Logs

## Pull Requests

Ein Pull Request schlägt Änderungen aus einem eigenen Branch für das Hauptprojekt vor.

1. Repository forken.
2. Einen fokussierten Branch wie `fix/shelf-drag` erstellen.
3. Eine klar abgegrenzte Änderung implementieren und testen.
4. Änderung committen.
5. Branch pushen.
6. Pull Request mit Testhinweisen und bei Bedarf Screenshots öffnen.

## Projekterwartungen

- Bestätigte Kernfunktionen nicht unbeabsichtigt entfernen.
- Native Apple-APIs bevorzugen.
- Dark Mode, VoiceOver, Tastaturbedienung und Reduce Motion berücksichtigen.
- Keine Secrets, Zertifikate, Team-IDs, Provisioning Profiles oder persönlichen Pfade committen.
- Große Architekturänderungen zuerst als Issue diskutieren.
