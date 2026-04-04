import SwiftUI

struct SessionSummaryView: View {
    let summary: SessionSummary
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("SESSION COMPLETE")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .tracking(2)

            Text("🎉")
                .font(.system(size: 48))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SummaryCell(value: "\(summary.steps)", label: "Steps", color: .green)
                SummaryCell(value: "\(summary.floors)", label: "Floors", color: .blue)
                SummaryCell(value: formatDuration(summary.duration), label: "Duration", color: .primary)
                SummaryCell(value: "\(Int(summary.calories))", label: "Calories", color: .orange)
            }

            if !summary.newlyUnlocked.isEmpty {
                VStack(spacing: 8) {
                    ForEach(summary.newlyUnlocked, id: \.id) { achievement in
                        HStack {
                            Image(systemName: "trophy.fill").foregroundStyle(.yellow)
                            Text(achievement.name).font(.subheadline.bold())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.yellow.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "heart.fill").foregroundStyle(.pink).font(.caption)
                Text("Saved to Apple Health").font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
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

private struct SummaryCell: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
