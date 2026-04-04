import SwiftUI

struct IdleView: View {
    @ObservedObject var historyVM: HistoryViewModel
    let onStart: () -> Void
    let onHistory: () -> Void
    let onAchievements: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("ELEVATE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(3)

            // Today's stats card
            VStack(alignment: .leading, spacing: 6) {
                Text("TODAY")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(historyVM.todaySteps)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)

                let goal = UserDefaults.standard.dailyStepGoal
                ProgressView(value: Double(historyVM.todaySteps), total: Double(goal))
                    .tint(.green)
                Text("Goal: \(Int(min(100.0, Double(historyVM.todaySteps) / Double(goal) * 100)))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Streak badge
            if historyVM.currentStreak > 0 {
                Label("\(historyVM.currentStreak)-day streak", systemImage: "flame.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Spacer()

            // Start button
            Button(action: onStart) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 90, height: 90)
                        .shadow(color: .green.opacity(0.4), radius: 16)
                    Image(systemName: "play.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.black)
                        .offset(x: 3)
                }
            }
            Text("Start Climbing")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            // Bottom pills
            HStack(spacing: 12) {
                Button(action: onHistory) {
                    Label("History", systemImage: "chart.bar.fill")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                Button(action: onAchievements) {
                    Label("Achievements", systemImage: "trophy.fill")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(.primary)
        }
        .padding()
        .onAppear { historyVM.load() }
    }
}
