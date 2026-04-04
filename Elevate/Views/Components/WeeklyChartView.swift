import SwiftUI

struct WeeklyChartView: View {
    /// 7 values, index 0 = today, index 6 = 6 days ago
    let dailySteps: [Int]

    private var maxSteps: Int {
        dailySteps.max().flatMap { $0 > 0 ? $0 : nil } ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(dailySteps.enumerated().reversed()), id: \.offset) { offset, steps in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(offset == 0 ? Color.green : Color.green.opacity(0.4))
                        .frame(height: barHeight(for: steps))
                    Text(dayLabel(for: offset))
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 60)
    }

    private func barHeight(for steps: Int) -> CGFloat {
        max(4, CGFloat(steps) / CGFloat(maxSteps) * 48)
    }

    private func dayLabel(for offset: Int) -> String {
        if offset == 0 { return "Today" }
        let day = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day)
    }
}
