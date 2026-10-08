import AppKit
import QuartzCore

@MainActor
enum PanelOpeningAnimator {
    static func present(
        panel: NSPanel,
        target: CGRect,
        opening: Bool
    ) {
        panel.contentView?.wantsLayer = true

        if opening {
            openFromAbove(panel: panel, target: target)
        } else if panel.frame != target {
            resizeFromTop(panel: panel, target: target)
        } else {
            panel.alphaValue = 1
            panel.makeKeyAndOrderFront(nil)
        }
    }

    private static func openFromAbove(
        panel: NSPanel,
        target: CGRect
    ) {
        let preset = PanelAnimationPreset.selected

        // Die vollständige schwarze/gläserne Panel-Fläche liegt sofort
        // bündig unter der Notch. Dadurch entsteht niemals eine Desktop-Lücke.
        panel.alphaValue = 1
        panel.setFrame(target, display: true)
        panel.makeKeyAndOrderFront(nil)

        guard preset != .none else {
            return
        }

        let duration = baseDuration(for: preset)
            / PanelAnimationPreset.speed

        TopDownContentAnimator.animateOpening(
            panel: panel,
            preset: preset,
            duration: duration
        )
    }

    private static func resizeFromTop(
        panel: NSPanel,
        target: CGRect
    ) {
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            panel.setFrame(target, display: true)
            return
        }

        let duration = 0.26 / PanelAnimationPreset.speed
        let topAnchoredTarget = CGRect(
            x: target.midX - target.width / 2,
            y: panel.frame.maxY - target.height,
            width: target.width,
            height: target.height
        )

        TopDownContentAnimator.animateResize(
            panel: panel,
            duration: duration
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(
                topAnchoredTarget,
                display: true
            )
        }
    }

    private static func baseDuration(
        for preset: PanelAnimationPreset
    ) -> TimeInterval {
        switch preset {
        case .waterfall: return 0.62
        case .liquidStretch: return 0.78
        case .snapDown: return 0.32
        case .none: return 0
        }
    }
}
