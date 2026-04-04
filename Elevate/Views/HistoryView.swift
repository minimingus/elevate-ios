import SwiftUI

struct HistoryView: View {
    @ObservedObject var vm: HistoryViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    WeeklyChartView(dailySteps: vm.weeklySteps)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                Section("Sessions") {
                    ForEach(vm.sessions, id: \.id) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline.bold())
                                Text("\(session.steps) steps · \(session.floors) floors")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if session.id == vm.personalBests.bestSessionId {
                                Image(systemName: "trophy.fill").foregroundStyle(.yellow)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .onAppear { vm.load() }
        }
    }
}
