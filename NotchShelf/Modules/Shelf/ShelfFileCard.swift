import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ShelfFileCard: View {
    let item: ShelfItem
    let localURL: URL
    let onPreview: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    private let cardWidth: CGFloat = 152
    private let previewSize = CGSize(
        width: 128,
        height: 98
    )

    var body: some View {
        LiquidGlassSurface(cornerRadius: 17) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    FileThumbnailView(
                        url: localURL,
                        size: previewSize
                    )

                    if isHovered {
                        Button(action: onPreview) {
                            Image(systemName: "eye.fill")
                                .font(.caption.weight(.semibold))
                                .frame(width: 27, height: 27)
                                .background(
                                    Circle()
                                        .fill(.black.opacity(0.68))
                                )
                        }
                        .buttonStyle(.plain)
                        .help("Quick Look")
                        .transition(
                            .scale.combined(with: .opacity)
                        )
                        .padding(6)
                    }
                }

                VStack(spacing: 3) {
                    Text(item.displayName)
                        .font(.caption.weight(.medium))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Text(
                        ByteCountFormatter.string(
                            fromByteCount: item.byteCount,
                            countStyle: .file
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                Text("Ziehen zum Exportieren")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .frame(height: 11)
                    .opacity(isHovered ? 1 : 0)
            }
            .padding(12)
            .frame(width: cardWidth)
            .frame(minHeight: 174)
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
            )
        }
        .scaleEffect(isHovered ? 1.018 : 1)
        .animation(
            .smooth(duration: 0.18),
            value: isHovered
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture(count: 2) {
            onPreview()
        }
        .onDrag {
            dragItemProvider()
        } preview: {
            dragPreview
        }
        .contextMenu {
            Button("Quick Look") {
                onPreview()
            }

            Button("Im Finder zeigen") {
                NSWorkspace.shared.activateFileViewerSelecting(
                    [localURL]
                )
            }

            Button("Datei öffnen") {
                NSWorkspace.shared.open(localURL)
            }

            Divider()

            Button(
                "Aus Schrank löschen",
                role: .destructive
            ) {
                FileThumbnailLoader.shared.invalidate(
                    for: localURL
                )
                onDelete()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Datei \(item.displayName), \(formattedSize)"
        )
        .accessibilityHint(
            "Doppelklick für Quick Look oder Datei aus dem Schrank ziehen"
        )
    }

    private var formattedSize: String {
        ByteCountFormatter.string(
            fromByteCount: item.byteCount,
            countStyle: .file
        )
    }

    private func dragItemProvider() -> NSItemProvider {
        if let provider = NSItemProvider(
            contentsOf: localURL
        ) {
            provider.suggestedName = item.originalFileName
            return provider
        }

        let provider = NSItemProvider()
        provider.suggestedName = item.originalFileName
        provider.registerFileRepresentation(
            forTypeIdentifier: UTType.data.identifier,
            fileOptions: [],
            visibility: .all
        ) { completion in
            completion(localURL, true, nil)
            return nil
        }
        return provider
    }

    private var dragPreview: some View {
        VStack(spacing: 7) {
            FileThumbnailView(
                url: localURL,
                size: CGSize(
                    width: 126,
                    height: 92
                )
            )

            Text(item.displayName)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .frame(maxWidth: 140)
        }
        .padding(10)
        .background(
            RoundedRectangle(
                cornerRadius: 15,
                style: .continuous
            )
            .fill(.ultraThinMaterial)
        )
    }
}
