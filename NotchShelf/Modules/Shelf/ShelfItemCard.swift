import AppKit
import SwiftUI

struct ShelfItemCard: View {
    let item: ShelfItem
    let localURL: URL
    let onPreview: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: localURL.path))
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .shadow(color: .black.opacity(0.30), radius: 4, y: 3)

            Text(item.displayName)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 112)

            Text(ByteCountFormatter.string(fromByteCount: item.byteCount, countStyle: .file))
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Button(action: onPreview) { Image(systemName: "eye") }
                    .help("Quick Look")
                Button(role: .destructive, action: onRemove) { Image(systemName: "trash") }
                    .help("Datei dauerhaft aus dem Schrank löschen")
            }
            .buttonStyle(.borderless)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.065)))
    }
}
