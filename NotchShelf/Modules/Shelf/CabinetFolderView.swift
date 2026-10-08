import SwiftUI

struct CabinetFolderView: View {
    let group: ShelfGroup
    let itemCount: Int
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: isSelected ? "folder.fill" : "folder")
                        .font(.system(size: 37, weight: .medium))
                        .foregroundStyle(
                            isSelected
                                ? Color.accentColor
                                : Color.yellow.opacity(0.92)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 2)

                    if itemCount > 0 {
                        Text("\(itemCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.black.opacity(0.72)))
                            .offset(x: 5, y: 3)
                    }
                }

                Text(group.name)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .frame(width: 92)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .white.opacity(0.13) : .clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
