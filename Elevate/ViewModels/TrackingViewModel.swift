import Foundation
import Combine
import SwiftData

struct SessionSummary: Identifiable {
    let id = UUID()
    let steps: Int
    let floors: Int
    let calories: Double
    let duration: TimeInterval
    let newlyUnlocked: [Achievement]
}

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var steps: Int = 0
    @Published private(set) var floors: Int = 0
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var calories: Double = 0
    @Published var summary: SessionSummary? = nil

    private let pipeline: SensorPipeline
    private let sessionRepo: SessionRepository
    private let achievementRepo: AchievementRepository
    private let healthKit: HealthKitService
    private var startDate: Date?
    private var timer: AnyCancellable?
    private var pipelineCancellables = Set<AnyCancellable>()
    private var weightKg: Double = 70.0

    init(pipeline: SensorPipeline, sessionRepo: SessionRepository,
         achievementRepo: AchievementRepository, healthKit: HealthKitService) {
        self.pipeline = pipeline
        self.sessionRepo = sessionRepo
        self.achievementRepo = achievementRepo
        self.healthKit = healthKit
    }

    func start() async {
        weightKg = await healthKit.bodyMassKg() ?? 70.0
        isRunning = true
        startDate = Date()
        elapsedTime = 0
        summary = nil

        pipeline.$steps
            .receive(on: RunLoop.main)
            .sink { [weak self] s in
                guard let self else { return }
                self.steps = s
                self.calories = CalorieEstimator.calories(steps: s, weightKg: self.weightKg)
            }
            .store(in: &pipelineCancellables)

        pipeline.$floors
            .receive(on: RunLoop.main)
            .sink { [weak self] f in self?.floors = f }
            .store(in: &pipelineCancellables)

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let start = self.startDate else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
            }

        pipeline.start()
    }

    func stop() async {
        timer?.cancel()
        timer = nil
        pipelineCancellables.removeAll()
        let (finalSteps, finalFloors) = pipeline.stop()
        let end = Date()
        let start = startDate ?? end
        isRunning = false

        let session = ClimbSession(
            startDate: start, endDate: end,
            steps: finalSteps, floors: finalFloors,
            calories: CalorieEstimator.calories(steps: finalSteps, weightKg: weightKg)
        )

        try? sessionRepo.save(session)
        try? await healthKit.write(session: session)

        let allSessions = (try? sessionRepo.fetchAll()) ?? []
        let lifetimeSteps = (try? sessionRepo.lifetimeSteps()) ?? 0
        let streak = currentStreak(from: allSessions)
        let candidateIds = AchievementEngine.evaluate(
            session: session, allSessions: allSessions,
            currentStreak: streak, lifetimeSteps: lifetimeSteps
        )
        let alreadyUnlocked = Set(((try? achievementRepo.fetchAll()) ?? [])
            .compactMap { $0.unlockedDate != nil ? $0.id : nil })
        let toUnlock = candidateIds.subtracting(alreadyUnlocked)
        try? achievementRepo.unlock(ids: toUnlock)

        let newAchievements = ((try? achievementRepo.fetchAll()) ?? [])
            .filter { toUnlock.contains($0.id) }

        summary = SessionSummary(
            steps: finalSteps, floors: finalFloors,
            calories: CalorieEstimator.calories(steps: finalSteps, weightKg: weightKg),
            duration: end.timeIntervalSince(start),
            newlyUnlocked: newAchievements
        )
    }

    var dailyGoalProgress: Double {
        let goal = UserDefaults.standard.dailyStepGoal
        return min(1.0, Double(steps) / Double(goal))
    }

    // MARK: - Private

    private func currentStreak(from sessions: [ClimbSession]) -> Int {
        let calendar = Calendar.current
        let goal = UserDefaults.standard.dailyStepGoal
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        while true {
            let end = calendar.date(byAdding: .day, value: 1, to: checkDate) ?? checkDate
            let daySteps = sessions.filter {
                $0.startDate >= checkDate && $0.startDate < end
            }.reduce(0) { $0 + $1.steps }
            if daySteps >= goal {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        return streak
    }
}
