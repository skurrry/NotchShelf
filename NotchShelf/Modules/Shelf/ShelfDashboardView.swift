import SwiftUI

struct ShelfDashboardView: View {
    @Bindable var appState: AppState
    @State private var confirmClear = false

    private let columns = [
        GridItem(
            .adaptive(minimum: 152),
            spacing: 14
        )
    ]

    var body: some View {
        LiquidGlassSurface(
            cornerRadius: 24,
            interactive: false
        ) {
            VStack(spacing: 14) {
                header
                shelfContent
            }
            .padding(16)
        }
        .alert(
            "Schrank leeren?",
            isPresented: $confirmClear
        ) {
            Button("Abbrechen", role: .cancel) { }

            Button(
                "Alle Dateien löschen",
                role: .destructive
            ) {
                FileThumbnailLoader.shared.removeAll()

                Task {
                    await appState.clearShelf()
                }
            }
        } message: {
            Text(
                "Alle dauerhaft gespeicherten Dateikopien werden gelöscht."
            )
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Label(
                "Dateischrank",
                systemImage: "cabinet.fill"
            )
            .font(.headline)

            Text(
                "\(appState.shelfItems.count) Dateien · \(appState.formattedShelfSize)"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .contentTransition(
                .numericText(
                    value: Double(
                        appState.shelfItems.count
                    )
                )
            )

            Spacer()

            Button(
                "Schrank leeren",
                role: .destructive
            ) {
                confirmClear = true
            }
            .disabled(appState.shelfItems.isEmpty)
        }
    }

    @ViewBuilder
    private var shelfContent: some View {
        if appState.isImportingFiles {
            ProgressView(
                "Dateien und Vorschauen werden vorbereitet …"
            )
            .frame(maxWidth: .infinity)
            .frame(minHeight: 190)
        } else if appState.shelfItems.isEmpty {
            ContentUnavailableView(
                "Schrank ist leer",
                systemImage: "tray.and.arrow.down.fill",
                description: Text(
                    "Ziehe Dateien zur Notch, um sie dauerhaft abzulegen."
                )
            )
            .frame(maxWidth: .infinity)
            .frame(minHeight: 190)
        } else {
            ScrollView {
                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: 14
                ) {
                    ForEach(appState.shelfItems) { item in
                        ShelfFileCard(
                            item: item,
                            localURL: appState.localURL(
                                for: item
                            ),
                            onPreview: {
                                appState.preview(item)
                            },
                            onDelete: {
                                Task {
                                    await appState.removeShelfItem(
                                        item
                                    )
                                }
                            }
                        )
                    }
                }
                .padding(4)
            }
            .frame(minHeight: 206)
        }
    }
}
