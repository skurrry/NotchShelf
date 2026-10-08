import AppKit
import CoreGraphics

struct NotchGeometry: Equatable {
    let notchFrame: CGRect
    let previewPanelFrame: CGRect
    let dashboardPanelFrame: CGRect

    /// Kleine Zone für normalen Hover direkt an der Notch.
    let hoverZoneFrame: CGRect

    /// Große Zone zur frühen Erkennung gezogener Dateien.
    let fileDragZoneFrame: CGRect
}

@MainActor
final class DisplayService {

    // MARK: - Built-in display

    func builtInScreen() -> NSScreen? {
        NSScreen.screens.first { screen in
            guard let displayID = screen.deviceDescription[
                NSDeviceDescriptionKey("NSScreenNumber")
            ] as? CGDirectDisplayID else {
                return false
            }

            return CGDisplayIsBuiltin(displayID) != 0
        }
    }

    // MARK: - Geometry

    func geometry(for screen: NSScreen) -> NotchGeometry? {
        let screenFrame = screen.frame
        let topInset = screen.safeAreaInsets.top

        guard topInset > 0 else {
            return nil
        }

        let notchWidth = calculateNotchWidth(for: screen)

        let notchFrame = CGRect(
            x: screenFrame.midX - notchWidth / 2,
            y: screenFrame.maxY - topInset,
            width: notchWidth,
            height: topInset
        )

        let previewPanelFrame = topCenteredFrame(
            size: CGSize(width: 390, height: 132),
            in: screenFrame
        )

        let dashboardPanelFrame = topCenteredFrame(
            size: CGSize(width: 540, height: 360),
            in: screenFrame
        )

        // Normales Hover bleibt eng an der physischen Notch.
        let hoverZoneFrame = CGRect(
            x: notchFrame.minX - 18,
            y: notchFrame.minY - 12,
            width: notchFrame.width + 36,
            height: notchFrame.height + 12
        )

        /*
         Sehr große Datei-Drag-Zone:

         - 760 Punkte breit
         - 280 Punkte tief
         - horizontal an der Notch zentriert
         - endet am oberen Bildschirmrand

         Dadurch wird ein Datei-Drag deutlich vor dem oberen Rand erkannt.
         Mission Control sollte gar nicht erst erreicht werden müssen.
        */
        let preferredDragZoneWidth: CGFloat = 900
        let dragZoneDepth: CGFloat = 360

        // Auf kleineren Displays bleibt links und rechts ein Sicherheitsabstand.
        let horizontalScreenMargin: CGFloat = 24
        let availableWidth = max(
            200,
            screenFrame.width - horizontalScreenMargin * 2
        )
        let dragZoneWidth = min(
            preferredDragZoneWidth,
            availableWidth
        )

        let fileDragZoneFrame = CGRect(
            x: screenFrame.midX - dragZoneWidth / 2,
            y: screenFrame.maxY - dragZoneDepth,
            width: dragZoneWidth,
            height: dragZoneDepth
        )

        return NotchGeometry(
            notchFrame: notchFrame,
            previewPanelFrame: previewPanelFrame,
            dashboardPanelFrame: dashboardPanelFrame,
            hoverZoneFrame: hoverZoneFrame,
            fileDragZoneFrame: fileDragZoneFrame
        )
    }

    // MARK: - Notch width

    private func calculateNotchWidth(for screen: NSScreen) -> CGFloat {
        guard
            let leftArea = screen.auxiliaryTopLeftArea,
            let rightArea = screen.auxiliaryTopRightArea
        else {
            return 190
        }

        let width = rightArea.minX - leftArea.maxX

        guard width.isFinite, width > 0 else {
            return 190
        }

        return max(width, 120)
    }

    // MARK: - Panel placement

    private func topCenteredFrame(
        size: CGSize,
        in screenFrame: CGRect
    ) -> CGRect {
        CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }
}
