import SwiftUI

struct SearchResultRow: View {
    let app: AppInfo
    let isSelected: Bool
    let isLowPriority: Bool
    let isHighPriority: Bool
    let alias: String?
    let fontSize: CGFloat
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 28, height: 28)

            Text(app.name)
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .lineLimit(1)

            if let alias = alias {
                Text("\"\(alias)\"")
                    .foregroundColor(.white.opacity(0.35))
                    .font(.system(size: fontSize * 0.85))
                    .lineLimit(1)
            }

            if isHighPriority {
                Image(systemName: "arrow.up")
                    .foregroundColor(.orange)
                    .font(.system(size: fontSize * 0.7))
            } else if isLowPriority {
                Image(systemName: "arrow.down")
                    .foregroundColor(.green)
                    .font(.system(size: fontSize * 0.7))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundFill)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var backgroundFill: Color {
        if isSelected {
            return Color.accentColor.opacity(0.3)
        } else if isHovered {
            return Color.white.opacity(0.08)
        } else {
            return Color.clear
        }
    }
}
