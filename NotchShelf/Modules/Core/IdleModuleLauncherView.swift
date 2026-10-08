import SwiftUI

struct IdleModuleLauncherView: View {
    let shelfCount: Int
    let onSelect: (DashboardTab) -> Void
    var body: some View {
        HStack(spacing: 8) {
            button(.shelf, badge: shelfCount > 0 ? shelfCount : nil)
            button(.timer)
            button(.clipboard)
            button(.status)
        }
    }
    private func button(_ tab: DashboardTab, badge: Int? = nil) -> some View {
        Button { onSelect(tab) } label: {
            HStack(spacing: 5) {
                Image(systemName: tab.symbol)
                Text(tab.title).font(.caption.weight(.semibold))
                if let badge { Text("\(badge)").font(.caption2.bold()).padding(.horizontal, 5).background(Capsule().fill(.blue)) }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.10)))
        }.buttonStyle(.plain)
    }
}
