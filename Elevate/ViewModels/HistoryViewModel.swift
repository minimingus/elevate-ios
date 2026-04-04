import Foundation
import Combine

struct PersonalBests {
    let maxSteps: Int
    let maxFloors: Int
    let maxDuration: TimeInterval
    let bestSessionId: UUID?
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var sessions: [ClimbSession] = []
    @Published private(set) var weeklySteps: [Int] = Array(repeating: 0, count: 7)
    @Published private(set) var personalBests = PersonalBests(maxSteps: 0, maxFloors: 0, maxDuration: 0, bestSessionId: nil)
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var todaySteps: Int = 0

    private let sessionRepo: SessionRepository

    init(sessionRepo: SessionRepository) {
        self.sessionRepo = sessionRepo
    }

    func load() {
        sessions = (try? sessionRepo.fetchAll()) ?? []
        weeklySteps = (try? sessionRepo.weeklySteps()) ?? Array(repeating: 0, count: 7)
        todaySteps = (try? sessionRepo.todaySteps()) ?? 0
        computePersonalBests()
        computeStreak()
    }

    private func computePersonalBests() {
        let maxStepsSession = sessions.max(by: { $0.steps < $1.steps })
        personalBests = PersonalBests(
            maxSteps: sessions.map(\.steps).max() ?? 0,
            maxFloors: sessions.map(\.floors).max() ?? 0,
            maxDuration: sessions.map(\.duration).max() ?? 0,
            bestSessionId: maxStepsSession?.id
        )
    }

    private func computeStreak() {
        currentStreak = calculateStreak(from: sessions, goal: UserDefaults.standard.dailyStepGoal)
    }
}
