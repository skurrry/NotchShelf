import SwiftUI

struct ClipboardCardView: View {
    @Bindable var clipboard: ClipboardModule

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Letzte Texte", systemImage: "doc.on.clipboard")
                    .font(.headline)
                Spacer()
                Button("Leeren") { clipboard.clear() }
                    .disabled(clipboard.items.isEmpty)
            }

            if clipboard.items.isEmpty {
                Text("Noch keine kopierten Texte in dieser Sitzung.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 70)
            } else {
                ForEach(clipboard.items.prefix(5)) { item in
                    Button {
                        clipboard.copyAgain(item)
                    } label: {
                        HStack {
                            Text(item.text)
                                .font(.caption)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "doc.on.doc")
                        }
                        .padding(9)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white.opacity(0.07))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.06))
        )
    }
}
