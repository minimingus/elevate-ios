import Foundation
import SwiftData

@MainActor
final class SessionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ session: ClimbSession) throws {
        modelContext.insert(session)
        try modelContext.save()
    }

    func fetchAll() throws -> [ClimbSession] {
        let descriptor = FetchDescriptor<ClimbSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func lifetimeSteps() throws -> Int {
        try fetchAll().reduce(0) { $0 + $1.steps }
    }

    func todaySteps() throws -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<ClimbSession>(
            predicate: #Predicate { $0.startDate >= startOfDay }
        )
        return try modelContext.fetch(descriptor).reduce(0) { $0 + $1.steps }
    }

    /// Returns step counts for the past `days` calendar days, index 0 = today, index 6 = 6 days ago.
    func weeklySteps(days: Int = 7) throws -> [Int] {
        let calendar = Calendar.current
        return try (0..<days).map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            let descriptor = FetchDescriptor<ClimbSession>(
                predicate: #Predicate { $0.startDate >= start && $0.startDate < end }
            )
            return try modelContext.fetch(descriptor).reduce(0) { $0 + $1.steps }
        }
    }
}
