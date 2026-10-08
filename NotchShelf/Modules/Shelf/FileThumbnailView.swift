import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct FileThumbnailView: View {
    let url: URL
    let size: CGSize

    @Environment(\.displayScale)
    private var displayScale

    @State private var thumbnail: NSImage?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: 11,
                style: .continuous
            )
            .fill(.black.opacity(0.20))

            if let thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .transition(.opacity)
            } else {
                Image(
                    nsImage: NSWorkspace.shared.icon(
                        forFile: url.path
                    )
                )
                .resizable()
                .scaledToFit()
                .frame(
                    width: min(54, size.width * 0.48),
                    height: min(54, size.height * 0.48)
                )
                .opacity(isLoading ? 0.66 : 1)
            }

            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomTrailing
                    )
                    .padding(8)
            }

            if isVideo {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.55))
                    .shadow(color: .black.opacity(0.32), radius: 4)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 11,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 11,
                style: .continuous
            )
            .stroke(.white.opacity(0.10), lineWidth: 1)
        }
        .task(id: thumbnailTaskID) {
            await loadThumbnail()
        }
        .accessibilityHidden(true)
    }

    private var thumbnailTaskID: String {
        [
            url.standardizedFileURL.path,
            String(Int(size.width)),
            String(Int(size.height)),
            String(format: "%.2f", displayScale)
        ]
        .joined(separator: "|")
    }

    private var isVideo: Bool {
        guard let type = try? url.resourceValues(
            forKeys: [.contentTypeKey]
        ).contentType else {
            return false
        }

        return type.conforms(to: .movie)
    }

    @MainActor
    private func loadThumbnail() async {
        isLoading = true

        let image = await FileThumbnailLoader.shared.thumbnail(
            for: url,
            size: size,
            scale: displayScale
        )

        guard !Task.isCancelled else {
            return
        }

        withAnimation(.easeInOut(duration: 0.18)) {
            thumbnail = image
            isLoading = false
        }
    }
}
