import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var showingAddAlarm = false
    @State private var editingAlarm: Alarm?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if alarmManager.alarms.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "alarm")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Alarms")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tap + to add an alarm")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    List {
                        ForEach(alarmManager.alarms) { alarm in
                            AlarmRowView(alarm: alarm)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingAlarm = alarm
                                }
                                .listRowBackground(Color(white: 0.11))
                        }
                        .onDelete(perform: deleteAlarms)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Autostop Alarms")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAlarm = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddAlarm) {
                AddEditAlarmView(mode: .add)
                    .environmentObject(alarmManager)
            }
            .sheet(item: $editingAlarm) { alarm in
                AddEditAlarmView(mode: .edit(alarm))
                    .environmentObject(alarmManager)
            }
        }
    }

    private func deleteAlarms(at offsets: IndexSet) {
        for index in offsets {
            alarmManager.deleteAlarm(alarmManager.alarms[index])
        }
    }
}

struct AlarmRowView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    let alarm: Alarm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 48, weight: .light, design: .default))
                    .foregroundColor(alarm.isEnabled ? .white : .gray)

                HStack(spacing: 6) {
                    Text(alarm.label)
                        .font(.subheadline)
                        .foregroundColor(alarm.isEnabled ? .white.opacity(0.7) : .gray.opacity(0.5))

                    if alarm.stopMode.isAutomatic {
                        Text("· \(alarm.stopMode.seconds)s")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(alarm.isEnabled ? 1.0 : 0.5))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(alarm.isEnabled ? 0.2 : 0.1))
                            )
                    }

                    if !alarm.repeatDays.isEmpty {
                        Text(repeatDaysText(alarm.repeatDays))
                            .font(.caption)
                            .foregroundColor(alarm.isEnabled ? .white.opacity(0.5) : .gray.opacity(0.3))
                    }
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in alarmManager.toggleAlarm(alarm) }
            ))
            .labelsHidden()
            .tint(.green)
        }
        .padding(.vertical, 4)
    }

    private func repeatDaysText(_ days: Set<Int>) -> String {
        let abbreviations = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        if days.count == 7 { return "Every day" }
        if days == [2, 3, 4, 5, 6] { return "Weekdays" }
        if days == [1, 7] { return "Weekends" }
        return days.sorted().map { abbreviations[$0] }.joined(separator: " ")
    }
}
