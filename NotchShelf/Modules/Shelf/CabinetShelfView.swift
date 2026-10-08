import SwiftUI

struct CabinetShelfView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)

            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.28, green: 0.17, blue: 0.10),
                                Color(red: 0.13, green: 0.08, blue: 0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Rectangle()
                    .fill(.white.opacity(0.10))
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(height: 14)
            .shadow(color: .black.opacity(0.55), radius: 7, y: 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.18),
                            Color.black.opacity(0.46)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}
