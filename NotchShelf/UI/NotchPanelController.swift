import AppKit
import SwiftUI

@MainActor
final class NotchPanelController: NSObject {
    private let appState: AppState
    private let displayService: DisplayService

    private let panel = NotchPanel(contentRect: .zero)
    private let hoverWindow = NSWindow(
        contentRect: .zero,
        styleMask: .borderless,
        backing: .buffered,
        defer: false
    )

    private var geometry: NotchGeometry?
    private var closeWorkItem: DispatchWorkItem?
    private var dashboardIsOpen = false
    private var dragIsActive = false

    private var globalDragMonitor: Any?
    private var globalMouseUpMonitor: Any?
    private var lastDragPasteboardChangeCount = -1
    private var cachedDraggedFileURLs: [URL] = []

    init(
        appState: AppState,
        displayService: DisplayService
    ) {
        self.appState = appState
        self.displayService = displayService
        super.init()

        configurePanel()
        configureHoverWindow()
        configureTimerCallbacks()
    }

    // MARK: - Lifecycle

    func start() {
        configureNotifications()
        configureGlobalDragMonitoring()
        refreshGeometry()
        hidePanel()
    }

    func stop() {
        cancelScheduledClose()
        removeGlobalDragMonitoring()
        NotificationCenter.default.removeObserver(self)
        panel.orderOut(nil)
        hoverWindow.orderOut(nil)
    }

    // MARK: - Public presentation

    func showPreview() {
        guard
            !appState.isSuppressedByFullScreen,
            !dragIsActive,
            !appState.timer.isAlarming,
            let frame = geometry?.previewPanelFrame
        else {
            return
        }

        cancelScheduledClose()
        dashboardIsOpen = false
        appState.panelMode = .preview
        appState.isPanelVisible = true
        hoverWindow.orderOut(nil)

        present(
            frame,
            opening: !panel.isVisible
        )

        scheduleCloseIfOutside()
    }

    func showDashboard(
        tab: DashboardTab? = nil
    ) {
        guard
            !appState.isSuppressedByFullScreen,
            !appState.timer.isAlarming,
            let frame = geometry?.dashboardPanelFrame
        else {
            return
        }

        if let tab {
            appState.selectedDashboardTab = tab
        }

        cancelScheduledClose()
        dashboardIsOpen = true
        appState.panelMode = .dashboard
        appState.isPanelVisible = true
        hoverWindow.orderOut(nil)

        present(
            frame,
            opening: !panel.isVisible
        )

        scheduleCloseIfOutside()
    }

    func collapseDashboard() {
        guard !appState.timer.isAlarming else {
            return
        }

        dashboardIsOpen = false
        showPreview()
    }

    func hidePanel() {
        guard
            !dragIsActive,
            !appState.timer.isAlarming
        else {
            return
        }

        cancelScheduledClose()
        dashboardIsOpen = false
        appState.panelMode = .idle
        appState.isPanelVisible = false
        appState.pendingDropURLs = []

        panel.alphaValue = 1
        panel.orderOut(nil)

        if !appState.isSuppressedByFullScreen,
           geometry != nil {
            hoverWindow.orderFrontRegardless()
        }
    }

    func showIdle(animated: Bool = true) {
        hidePanel()
    }

    func hideImmediately() {
        guard !appState.timer.isAlarming else {
            return
        }

        dragIsActive = false
        resetDragPasteboardCache()
        hidePanel()
    }

    func setFullScreenSuppressed(
        _ suppressed: Bool
    ) {
        appState.isSuppressedByFullScreen = suppressed

        if suppressed,
           !appState.timer.isAlarming {
            cancelScheduledClose()
            dragIsActive = false
            dashboardIsOpen = false
            resetDragPasteboardCache()

            panel.orderOut(nil)
            hoverWindow.orderOut(nil)

            appState.panelMode = .idle
            appState.isPanelVisible = false
        } else if !suppressed {
            refreshGeometry()
            hidePanel()
        }
    }

    // MARK: - Timer alarm

    private func configureTimerCallbacks() {
        appState.timer.onAlarmStarted = { [weak self] in
            self?.showTimerAlarm()
        }

        appState.timer.onAlarmStopped = { [weak self] in
            guard let self else {
                return
            }

            appState.selectedDashboardTab = .timer
            appState.panelMode = .dashboard
            dashboardIsOpen = true
            scheduleCloseIfOutside()
        }
    }

    private func showTimerAlarm() {
        guard let frame = geometry?.dashboardPanelFrame else {
            return
        }

        dragIsActive = false
        dashboardIsOpen = true
        resetDragPasteboardCache()
        cancelScheduledClose()

        appState.selectedDashboardTab = .timer
        appState.panelMode = .alarm
        appState.isPanelVisible = true

        hoverWindow.orderOut(nil)

        present(
            frame,
            opening: !panel.isVisible
        )

        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Panel content

    private func configurePanel() {
        let rootView = PanelRootView(
            appState: appState,
            onOpenTab: { [weak self] tab in
                self?.showDashboard(tab: tab)
            },
            onCollapse: { [weak self] in
                self?.collapseDashboard()
            },
            onClose: { [weak self] in
                self?.hidePanel()
            }
        )

        let hostingController = NSHostingController(
            rootView: rootView
        )
        let containerController = NSViewController()
        let interactionView = DragAwareView(frame: .zero)

        containerController.view = interactionView
        containerController.addChild(hostingController)

        let hostedView = hostingController.view
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.wantsLayer = true
        hostedView.layer?.backgroundColor = NSColor.clear.cgColor

        interactionView.addSubview(hostedView)

        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(
                equalTo: interactionView.leadingAnchor
            ),
            hostedView.trailingAnchor.constraint(
                equalTo: interactionView.trailingAnchor
            ),
            hostedView.topAnchor.constraint(
                equalTo: interactionView.topAnchor
            ),
            hostedView.bottomAnchor.constraint(
                equalTo: interactionView.bottomAnchor
            )
        ])

        interactionView.onMouseEntered = { [weak self] in
            self?.cancelScheduledClose()
        }

        interactionView.onMouseExited = { [weak self] in
            self?.scheduleClose()
        }

        interactionView.onFileDragEntered = { [weak self] urls in
            self?.showDropTarget(urls)
        }

        interactionView.onFileDragUpdated = { [weak self] urls in
            self?.updateDropTarget(urls)
        }

        interactionView.onFileDragExited = { [weak self] in
            self?.cancelFileDrag()
        }

        interactionView.onFileDrop = { [weak self] urls in
            self?.acceptFileDrop(urls) ?? false
        }

        panel.contentViewController = containerController

        panel.onEscape = { [weak self] in
            guard let self,
                  !appState.timer.isAlarming
            else {
                return
            }

            if dragIsActive {
                cancelFileDrag()
            } else if dashboardIsOpen {
                collapseDashboard()
            } else {
                hidePanel()
            }
        }
    }

    // MARK: - Hover window

    private func handleNotchHoverEntered() {
        guard
            !appState.isSuppressedByFullScreen,
            !dragIsActive,
            !appState.timer.isAlarming
        else {
            return
        }

        // Bestätigte Kernanforderung:
        // Sobald mindestens eine Datei im Shelf liegt, öffnet die
        // Mausannäherung direkt das Shelf-Dashboard. Nur ein leeres
        // Shelf zeigt zuerst die kompakte Tagesleiste.
        if appState.shelfItems.isEmpty {
            showPreview()
        } else {
            showDashboard(tab: .shelf)
        }
    }

    private func configureHoverWindow() {
        let view = DragAwareView(frame: .zero)

        view.onMouseEntered = { [weak self] in
            self?.handleNotchHoverEntered()
        }

        view.onFileDragEntered = { [weak self] urls in
            self?.showDropTarget(urls)
        }

        view.onFileDragUpdated = { [weak self] urls in
            self?.updateDropTarget(urls)
        }

        view.onFileDragExited = { [weak self] in
            self?.cancelFileDrag()
        }

        view.onFileDrop = { [weak self] urls in
            self?.acceptFileDrop(urls) ?? false
        }

        hoverWindow.contentView = view
        hoverWindow.backgroundColor = .clear
        hoverWindow.isOpaque = false
        hoverWindow.hasShadow = false
        hoverWindow.level = .statusBar
        hoverWindow.isReleasedWhenClosed = false
        hoverWindow.collectionBehavior = [
            .canJoinAllSpaces,
            .stationary
        ]
    }

    // MARK: - Global file drag

    private func configureGlobalDragMonitoring() {
        removeGlobalDragMonitoring()

        globalDragMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDragged]
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleGlobalFileDrag()
            }
        }

        globalMouseUpMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseUp]
        ) { [weak self] _ in
            Task { @MainActor in
                self?.endGlobalDrag()
            }
        }
    }

    private func removeGlobalDragMonitoring() {
        if let globalDragMonitor {
            NSEvent.removeMonitor(globalDragMonitor)
        }

        if let globalMouseUpMonitor {
            NSEvent.removeMonitor(globalMouseUpMonitor)
        }

        globalDragMonitor = nil
        globalMouseUpMonitor = nil
    }

    private func handleGlobalFileDrag() {
        guard !appState.isSuppressedByFullScreen else {
            return
        }

        if DragActivationMode.selected == .nearNotch {
            guard
                let zone = geometry?.fileDragZoneFrame,
                zone.contains(NSEvent.mouseLocation)
            else {
                return
            }
        }

        let urls = draggedFileURLsIfAvailable()

        guard !urls.isEmpty else {
            return
        }

        showDropTarget(urls)
    }

    private func draggedFileURLsIfAvailable() -> [URL] {
        let pasteboard = NSPasteboard(name: .drag)
        let changeCount = pasteboard.changeCount

        if changeCount == lastDragPasteboardChangeCount {
            return cachedDraggedFileURLs
        }

        lastDragPasteboardChangeCount = changeCount

        guard pasteboard.types?.contains(.fileURL) == true else {
            cachedDraggedFileURLs = []
            return []
        }

        let options: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
        ]

        guard pasteboard.canReadObject(
            forClasses: [NSURL.self],
            options: options
        ) else {
            cachedDraggedFileURLs = []
            return []
        }

        let objects = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: options
        ) ?? []

        let urls = objects.compactMap { object -> URL? in
            guard let url = object as? URL,
                  url.isFileURL
            else {
                return nil
            }

            return url
        }

        cachedDraggedFileURLs = urls
        return urls
    }

    private func resetDragPasteboardCache() {
        lastDragPasteboardChangeCount = -1
        cachedDraggedFileURLs = []
    }

    private func endGlobalDrag() {
        resetDragPasteboardCache()

        guard dragIsActive else {
            return
        }

        dragIsActive = false
        appState.pendingDropURLs = []

        if panel.isVisible,
           appState.panelMode != .dashboard {
            appState.panelMode = .dashboard
            appState.selectedDashboardTab = .shelf
            dashboardIsOpen = true
            scheduleCloseIfOutside()
        }
    }

    // MARK: - File drop

    private func showDropTarget(
        _ urls: [URL]
    ) {
        guard
            !urls.isEmpty,
            !appState.timer.isAlarming,
            let frame = geometry?.dashboardPanelFrame
        else {
            return
        }

        dragIsActive = true
        dashboardIsOpen = true
        cancelScheduledClose()

        appState.selectedDashboardTab = .shelf
        appState.pendingDropURLs = urls
        appState.panelMode = .dropTarget(
            itemCount: urls.count
        )
        appState.isPanelVisible = true

        hoverWindow.orderOut(nil)

        present(
            frame,
            opening: !panel.isVisible
        )
    }

    private func updateDropTarget(
        _ urls: [URL]
    ) {
        guard !urls.isEmpty else {
            return
        }

        dragIsActive = true
        appState.pendingDropURLs = urls
        appState.panelMode = .dropTarget(
            itemCount: urls.count
        )
    }

    private func cancelFileDrag() {
        dragIsActive = false
        resetDragPasteboardCache()
        appState.pendingDropURLs = []
        appState.selectedDashboardTab = .shelf
        appState.panelMode = .dashboard
        dashboardIsOpen = true
        scheduleClose()
    }

    private func acceptFileDrop(
        _ urls: [URL]
    ) -> Bool {
        guard !urls.isEmpty else {
            return false
        }

        dragIsActive = false
        resetDragPasteboardCache()
        dashboardIsOpen = true

        appState.pendingDropURLs = []
        appState.selectedDashboardTab = .shelf
        appState.panelMode = .dashboard

        cancelScheduledClose()

        Task { [weak self] in
            guard let self else {
                return
            }

            await appState.importFiles(urls)
        }

        return true
    }

    // MARK: - Automatic closing

    private func scheduleClose() {
        guard
            !dragIsActive,
            !appState.timer.isAlarming
        else {
            return
        }

        cancelScheduledClose()

        let item = DispatchWorkItem { [weak self] in
            guard let self,
                  !isMouseInsidePanel()
            else {
                return
            }

            hidePanel()
        }

        closeWorkItem = item

        DispatchQueue.main.asyncAfter(
            deadline: .now()
                + CloseDelayPreset.selected.duration,
            execute: item
        )
    }

    private func scheduleCloseIfOutside() {
        DispatchQueue.main.async { [weak self] in
            guard
                let self,
                !dragIsActive,
                !appState.timer.isAlarming
            else {
                return
            }

            if isMouseInsidePanel() {
                cancelScheduledClose()
            } else {
                scheduleClose()
            }
        }
    }

    private func isMouseInsidePanel() -> Bool {
        panel.isVisible
            && panel.frame.contains(
                NSEvent.mouseLocation
            )
    }

    private func cancelScheduledClose() {
        closeWorkItem?.cancel()
        closeWorkItem = nil
    }

    // MARK: - Animation

    private func present(
        _ frame: CGRect,
        opening: Bool
    ) {
        PanelOpeningAnimator.present(
            panel: panel,
            target: frame,
            opening: opening
        )

        NSApp.activate(
            ignoringOtherApps: true
        )
    }

    // MARK: - Geometry

    private func refreshGeometry() {
        guard
            let screen = displayService.builtInScreen(),
            let newGeometry = displayService.geometry(
                for: screen
            )
        else {
            geometry = nil
            panel.orderOut(nil)
            hoverWindow.orderOut(nil)
            return
        }

        geometry = newGeometry
        hoverWindow.setFrame(
            newGeometry.hoverZoneFrame,
            display: true
        )

        if !panel.isVisible {
            hoverWindow.orderFrontRegardless()
        }
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                screenParametersDidChange
            ),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc
    private func screenParametersDidChange(
        _ notification: Notification
    ) {
        refreshGeometry()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
