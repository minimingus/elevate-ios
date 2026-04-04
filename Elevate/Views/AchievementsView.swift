import SwiftUI

struct AchievementsView: View {
    @ObservedObject var vm: AchievementViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(vm.achievements) { achievement in
                        VStack(spacing: 6) {
                            Text(achievement.emoji)
                                .font(.system(size: 32))
                            Text(achievement.name)
                                .font(.caption2.bold())
                                .multilineTextAlignment(.center)
                            if let progress = achievement.progress {
                                Text(progress)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .opacity(achievement.isUnlocked ? 1.0 : 0.4)
                    }
                }
                .padding()

                Text("\(vm.achievements.filter(\.isUnlocked).count) of \(vm.achievements.count) unlocked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("Achievements")
            .onAppear { vm.load() }
        }
    }
}
