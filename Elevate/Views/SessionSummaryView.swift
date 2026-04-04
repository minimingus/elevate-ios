import SwiftUI

// MARK: - Landmark comparisons

private struct Landmark {
    let name: String
    let emoji: String
    let steps: Int
}

private let landmarks: [Landmark] = [
    Landmark(name: "Leaning Tower of Pisa",  emoji: "🗼", steps: 294),
    Landmark(name: "Statue of Liberty",       emoji: "🗽", steps: 354),
    Landmark(name: "Big Ben",                 emoji: "🕰️", steps: 334),
    Landmark(name: "Sydney Opera House",      emoji: "🎭", steps: 200),
    Landmark(name: "Eiffel Tower",            emoji: "🗼", steps: 1665),
    Landmark(name: "Empire State Building",   emoji: "🏙️", steps: 1860),
    Landmark(name: "CN Tower",                emoji: "📡", steps: 1776),
    Landmark(name: "Burj Khalifa",            emoji: "🏗️", steps: 2909),
]

private func landmarkComparison(for steps: Int) -> String? {
    guard steps > 0 else { return nil }
    // Find the landmark whose steps divides most evenly into our count
    let best = landmarks
        .filter { steps >= $0.steps }
        .max(by: { $0.steps < $1.steps })
    guard let best else {
        // Didn't reach any landmark — show fraction of closest
        if let closest = landmarks.min(by: { $0.steps < $1.steps }) {
            let pct = Int(Double(steps) / Double(closest.steps) * 100)
            return "\(pct)% of the way up \(closest.name) \(closest.emoji)"
        }
        return nil
    }
    let times = steps / best.steps
    let remainder = steps % best.steps
    let fraction = Double(remainder) / Double(best.steps)

    if times == 1 && fraction < 0.15 {
        return "That's like climbing \(best.name)! \(best.emoji)"
    } else if times >= 2 {
        return "Like climbing \(best.name) \(times)× \(best.emoji)"
    } else {
        let pct = Int((Double(times) + fraction) * 100)
        return "\(pct)% of \(best.name) \(best.emoji)"
    }
}

// MARK: - Share card

struct ShareCard: View {
    let summary: SessionSummary

    private func formatDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Color(red: 10/255, green: 10/255, blue: 11/255)

            VStack(spacing: 0) {
                // Top accent bar
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 4)

                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ELEVATE")
                                .font(.caption.bold())
                                .foregroundStyle(.green)
                                .tracking(3)
                            Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "figure.stair.stepper")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }

                    // Big step count
                    VStack(spacing: 4) {
                        Text("\(summary.steps)")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text("steps climbed")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Stats row
                    HStack(spacing: 0) {
                        CardStat(value: "\(summary.floors)", label: "floors")
                        Divider().frame(height: 36).background(Color(.systemGray4))
                        CardStat(value: formatDuration(summary.duration), label: "time")
                        Divider().frame(height: 36).background(Color(.systemGray4))
                        CardStat(value: "\(Int(summary.calories))", label: "cal")
                    }

                    // Landmark
                    if let landmark = landmarkComparison(for: summary.steps) {
                        Text(landmark)
                            .font(.subheadline.bold())
                            .foregroundStyle(.green)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 360, height: 320)
    }
}

private struct CardStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Summary view

struct SessionSummaryView: View {
    let summary: SessionSummary
    let onDone: () -> Void

    @State private var shareImage: Image? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("SESSION COMPLETE")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .tracking(2)
                .padding(.top, 4)

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SummaryCell(value: "\(summary.steps)", label: "Steps", color: .green)
                SummaryCell(value: "\(summary.floors)", label: "Floors", color: .blue)
                SummaryCell(value: formatDuration(summary.duration), label: "Duration", color: .primary)
                SummaryCell(value: "\(Int(summary.calories))", label: "Calories", color: .orange)
            }

            // Landmark comparison
            if let landmark = landmarkComparison(for: summary.steps) {
                HStack(spacing: 8) {
                    Text(landmark)
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Achievements
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

            // Share + Done
            HStack(spacing: 12) {
                if let shareImage {
                    ShareLink(item: shareImage, preview: SharePreview("My Elevate session", image: shareImage)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Button(action: onDone) {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding()
        .task { await renderShareCard() }
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }

    @MainActor
    private func renderShareCard() async {
        let renderer = ImageRenderer(content: ShareCard(summary: summary))
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage {
            shareImage = Image(uiImage: uiImage)
        }
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
