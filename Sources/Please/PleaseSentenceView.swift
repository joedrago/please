import SwiftUI

struct PleaseSentenceView: View {
    let appName: String?

    var body: some View {
        HStack(spacing: 0) {
            Text("Please")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            if let appName {
                Text(" open ")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))

                Text(appName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.accentColor)
            }

            Spacer()
        }
    }
}
