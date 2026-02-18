import SwiftUI

struct SearchResultRow: View {
    let app: AppInfo
    let isSelected: Bool
    let fontSize: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 28, height: 28)

            Text(app.name)
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(
            isSelected
                ? RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.3))
                : nil
        )
        .contentShape(Rectangle())
    }
}
