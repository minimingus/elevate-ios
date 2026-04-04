import SwiftUI

struct RingProgressView: View {
    let progress: Double   // 0.0–1.0
    let steps: Int
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            VStack(spacing: 2) {
                Text("\(steps)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                Text("steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
