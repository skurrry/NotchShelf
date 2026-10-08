import AppKit
import QuartzCore

@MainActor
enum TopDownContentAnimator {
    static func animateOpening(
        panel: NSPanel,
        preset: PanelAnimationPreset,
        duration: TimeInterval
    ) {
        guard
            preset != .none,
            !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion,
            let contentView = panel.contentView
        else {
            return
        }

        contentView.wantsLayer = true
        guard let layer = contentView.layer else {
            return
        }

        layer.removeAnimation(forKey: "NotchShelf.correctTopDown")
        preservePositionWhileSettingTopAnchor(layer)

        let height = max(panel.frame.height, 1)
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = .removed

        switch preset {
        case .waterfall:
            animation.values = [
                transform(scaleX: 1.00, scaleY: 0.04, moveUp: height * 1.06),
                transform(scaleX: 1.00, scaleY: 1.035, moveUp: 0),
                CATransform3DIdentity
            ].map(NSValue.init(caTransform3D:))
            animation.keyTimes = [0, 0.80, 1]

        case .liquidStretch:
            animation.values = [
                transform(scaleX: 0.76, scaleY: 0.025, moveUp: height * 1.12),
                transform(scaleX: 1.025, scaleY: 1.075, moveUp: 0),
                transform(scaleX: 0.995, scaleY: 0.985, moveUp: 0),
                CATransform3DIdentity
            ].map(NSValue.init(caTransform3D:))
            animation.keyTimes = [0, 0.67, 0.88, 1]

        case .snapDown:
            animation.values = [
                transform(scaleX: 0.90, scaleY: 0.08, moveUp: height * 0.92),
                transform(scaleX: 1.01, scaleY: 1.055, moveUp: 0),
                CATransform3DIdentity
            ].map(NSValue.init(caTransform3D:))
            animation.keyTimes = [0, 0.72, 1]

        case .none:
            return
        }

        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "NotchShelf.correctTopDown")
    }

    static func animateResize(
        panel: NSPanel,
        duration: TimeInterval
    ) {
        guard
            !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion,
            let layer = panel.contentView?.layer
        else {
            return
        }

        preservePositionWhileSettingTopAnchor(layer)

        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0.975, 1.006, 1.0]
        animation.keyTimes = [0, 0.74, 1]
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        layer.add(animation, forKey: "NotchShelf.resizeZoom")
    }

    private static func transform(
        scaleX: CGFloat,
        scaleY: CGFloat,
        moveUp: CGFloat
    ) -> CATransform3D {
        // Core Animation nutzt im AppKit-Layer positive Y-Werte nach oben.
        // Der Inhalt startet oberhalb des sichtbaren Panels und bewegt sich
        // beim Übergang auf 0 ausschließlich nach unten.
        var value = CATransform3DMakeTranslation(0, moveUp, 0)
        value = CATransform3DScale(value, scaleX, scaleY, 1)
        return value
    }

    private static func preservePositionWhileSettingTopAnchor(
        _ layer: CALayer
    ) {
        let oldAnchor = layer.anchorPoint
        let newAnchor = CGPoint(x: 0.5, y: 1.0)

        guard oldAnchor != newAnchor else {
            return
        }

        let oldPoint = CGPoint(
            x: layer.bounds.width * oldAnchor.x,
            y: layer.bounds.height * oldAnchor.y
        )
        let newPoint = CGPoint(
            x: layer.bounds.width * newAnchor.x,
            y: layer.bounds.height * newAnchor.y
        )

        layer.position = CGPoint(
            x: layer.position.x + newPoint.x - oldPoint.x,
            y: layer.position.y + newPoint.y - oldPoint.y
        )
        layer.anchorPoint = newAnchor
    }
}
