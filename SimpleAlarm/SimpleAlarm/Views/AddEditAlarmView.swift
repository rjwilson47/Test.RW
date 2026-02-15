import SwiftUI

enum AlarmEditMode: Identifiable {
    case add
    case edit(Alarm)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let alarm): return alarm.id.uuidString
        }
    }
}

struct AddEditAlarmView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Environment(\.dismiss) var dismiss

    let mode: AlarmEditMode

    @State private var selectedTime: Date
    @State private var label: String
    @State private var stopMode: AlarmStopMode
    @State private var autoStopSeconds: Int
    @State private var repeatDays: Set<Int>
    @State private var snoozeEnabled: Bool
    @State private var sound: AlarmSound
    @State private var showDeleteConfirm = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    init(mode: AlarmEditMode) {
        self.mode = mode

        let calendar = Calendar.current
        switch mode {
        case .add:
            let now = Date()
            _selectedTime = State(initialValue: now)
            _label = State(initialValue: "Alarm")
            _stopMode = State(initialValue: .manual)
            _autoStopSeconds = State(initialValue: 20)
            _repeatDays = State(initialValue: [])
            _snoozeEnabled = State(initialValue: true)
            _sound = State(initialValue: .pulse)

        case .edit(let alarm):
            var components = DateComponents()
            components.hour = alarm.hour
            components.minute = alarm.minute
            let date = calendar.date(from: components) ?? Date()
            _selectedTime = State(initialValue: date)
            _label = State(initialValue: alarm.label)
            _stopMode = State(initialValue: alarm.stopMode)
            _autoStopSeconds = State(initialValue: alarm.stopMode.isAutomatic ? alarm.stopMode.seconds : 20)
            _repeatDays = State(initialValue: alarm.repeatDays)
            _snoozeEnabled = State(initialValue: alarm.snoozeEnabled)
            _sound = State(initialValue: alarm.sound)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Time Picker
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(.top, 8)
                            .colorScheme(.dark)

                        VStack(spacing: 0) {
                            // Label
                            settingsRow(title: "Label") {
                                TextField("Alarm", text: $label)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.trailing)
                            }

                            Divider().background(Color.gray.opacity(0.3))

                            // Repeat Days
                            NavigationLink {
                                RepeatDaysView(selectedDays: $repeatDays)
                            } label: {
                                settingsRow(title: "Repeat") {
                                    Text(repeatSummary)
                                        .foregroundColor(.gray)
                                }
                            }

                            Divider().background(Color.gray.opacity(0.3))

                            // Sound Selection
                            NavigationLink {
                                SoundSelectionView(selectedSound: $sound)
                            } label: {
                                settingsRow(title: "Sound") {
                                    Text(sound.rawValue)
                                        .foregroundColor(.gray)
                                }
                            }

                            Divider().background(Color.gray.opacity(0.3))

                            // Snooze Toggle
                            settingsRow(title: "Snooze") {
                                Toggle("", isOn: $snoozeEnabled)
                                    .labelsHidden()
                                    .tint(.blue)
                            }

                            Divider().background(Color.gray.opacity(0.3))

                            // Stop Mode
                            VStack(spacing: 0) {
                                settingsRow(title: "Alarm Duration") {
                                    EmptyView()
                                }

                                Picker("", selection: Binding(
                                    get: { stopMode.isAutomatic },
                                    set: { isAuto in
                                        stopMode = isAuto ? .automatic(seconds: autoStopSeconds) : .manual
                                    }
                                )) {
                                    Text("Until turned off").tag(false)
                                    Text("Auto-stop").tag(true)
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)

                                if stopMode.isAutomatic {
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text("Stop after")
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("\(autoStopSeconds) seconds")
                                                .foregroundColor(.blue)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 16)

                                        Slider(
                                            value: Binding(
                                                get: { Double(autoStopSeconds) },
                                                set: { newVal in
                                                    autoStopSeconds = Int(newVal)
                                                    stopMode = .automatic(seconds: autoStopSeconds)
                                                }
                                            ),
                                            in: 5...300,
                                            step: 5
                                        )
                                        .tint(.blue)
                                        .padding(.horizontal, 16)

                                        HStack {
                                            Text("5s")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("5m")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    .padding(.bottom, 12)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }
                        .background(Color(white: 0.11))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // Delete button for editing
                        if isEditing {
                            Button(role: .destructive) {
                                showDeleteConfirm = true
                            } label: {
                                Text("Delete Alarm")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(white: 0.11))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Alarm" : "Add Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAlarm() }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            .alert("Delete Alarm", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    if case .edit(let alarm) = mode {
                        alarmManager.deleteAlarm(alarm)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this alarm?")
            }
            .animation(.easeInOut(duration: 0.25), value: stopMode.isAutomatic)
        }
    }

    private func settingsRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var repeatSummary: String {
        if repeatDays.isEmpty { return "Never" }
        if repeatDays.count == 7 { return "Every day" }
        if repeatDays == [2, 3, 4, 5, 6] { return "Weekdays" }
        if repeatDays == [1, 7] { return "Weekends" }
        let abbreviations = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return repeatDays.sorted().map { abbreviations[$0] }.joined(separator: " ")
    }

    private func saveAlarm() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)

        let finalStopMode: AlarmStopMode = stopMode.isAutomatic
            ? .automatic(seconds: autoStopSeconds)
            : .manual

        switch mode {
        case .add:
            let alarm = Alarm(
                hour: hour,
                minute: minute,
                isEnabled: true,
                label: label.isEmpty ? "Alarm" : label,
                stopMode: finalStopMode,
                repeatDays: repeatDays,
                snoozeEnabled: snoozeEnabled,
                sound: sound
            )
            alarmManager.addAlarm(alarm)

        case .edit(var alarm):
            alarm.hour = hour
            alarm.minute = minute
            alarm.label = label.isEmpty ? "Alarm" : label
            alarm.stopMode = finalStopMode
            alarm.repeatDays = repeatDays
            alarm.snoozeEnabled = snoozeEnabled
            alarm.sound = sound
            alarmManager.updateAlarm(alarm)
        }

        dismiss()
    }
}

// MARK: - Repeat Days Selection

struct RepeatDaysView: View {
    @Binding var selectedDays: Set<Int>

    private let dayNames = [
        (1, "Every Sunday"),
        (2, "Every Monday"),
        (3, "Every Tuesday"),
        (4, "Every Wednesday"),
        (5, "Every Thursday"),
        (6, "Every Friday"),
        (7, "Every Saturday")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            List {
                ForEach(dayNames, id: \.0) { day in
                    Button {
                        if selectedDays.contains(day.0) {
                            selectedDays.remove(day.0)
                        } else {
                            selectedDays.insert(day.0)
                        }
                    } label: {
                        HStack {
                            Text(day.1)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedDays.contains(day.0) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .listRowBackground(Color(white: 0.11))
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Repeat")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Sound Selection

struct SoundSelectionView: View {
    @Binding var selectedSound: AlarmSound
    @EnvironmentObject var alarmManager: AlarmManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            List {
                ForEach(AlarmSound.allCases, id: \.self) { sound in
                    Button {
                        selectedSound = sound
                        alarmManager.previewSound(sound)
                    } label: {
                        HStack {
                            Image(systemName: sound.iconName)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text(sound.rawValue)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedSound == sound {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .listRowBackground(Color(white: 0.11))
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Sound")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onDisappear {
            alarmManager.stopPreview()
        }
    }
}
