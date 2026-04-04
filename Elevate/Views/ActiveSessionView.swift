import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var trackingVM: TrackingViewModel
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("ACTIVE SESSION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(3)

            RingProgressView(progress: trackingVM.dailyGoalProgress, steps: trackingVM.steps)
                .frame(width: 200, height: 200)

            HStack(spacing: 32) {
                StatCell(value: "\(trackingVM.floors)", label: "floors", color: .blue)
                StatCell(value: formatDuration(trackingVM.elapsedTime), label: "time", color: .primary)
                StatCell(value: "\(Int(trackingVM.calories))", label: "cal", color: .orange)
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                    .opacity(trackingVM.steps > 0 ? 1 : 0.4)
                Text("Detecting steps...")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            Spacer()

            Button(action: onStop) {
                Text("Stop")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

private struct StatCell: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
