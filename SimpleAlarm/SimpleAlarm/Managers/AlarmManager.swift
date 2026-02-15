import Foundation
import UserNotifications
import AVFoundation
import Combine

class AlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var firingAlarm: Alarm?
    @Published var isAlarmFiring: Bool = false

    private var audioPlayer: AVAudioPlayer?
    private var autoStopTimer: Timer?
    private var checkTimer: Timer?

    private let saveKey = "saved_alarms"

    init() {
        loadAlarms()
        requestNotificationPermission()
        startCheckTimer()
    }

    // MARK: - Persistence

    func loadAlarms() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return
        }
        alarms = decoded
    }

    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    // MARK: - CRUD

    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        saveAlarms()
        scheduleNotification(for: alarm)
    }

    func updateAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            saveAlarms()
            cancelNotification(for: alarm)
            if alarm.isEnabled {
                scheduleNotification(for: alarm)
            }
        }
    }

    func deleteAlarm(_ alarm: Alarm) {
        cancelNotification(for: alarm)
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }

    func toggleAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isEnabled.toggle()
            saveAlarms()
            if alarms[index].isEnabled {
                scheduleNotification(for: alarms[index])
            } else {
                cancelNotification(for: alarms[index])
            }
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleNotification(for alarm: Alarm) {
        guard alarm.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = alarm.label
        content.body = "Alarm - \(alarm.timeString)"
        content.sound = UNNotificationSound.default
        content.userInfo = ["alarmId": alarm.id.uuidString]

        var dateComponents = DateComponents()
        dateComponents.hour = alarm.hour
        dateComponents.minute = alarm.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: !alarm.repeatDays.isEmpty)

        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [alarm.id.uuidString]
        )
    }

    // MARK: - Alarm Firing (In-App)

    private func startCheckTimer() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkAlarms()
        }
    }

    private func checkAlarms() {
        guard !isAlarmFiring else { return }

        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)

        // Only fire at :00 seconds to avoid re-firing
        guard currentSecond == 0 else { return }

        for alarm in alarms where alarm.isEnabled {
            if alarm.hour == currentHour && alarm.minute == currentMinute {
                if alarm.repeatDays.isEmpty || alarm.repeatDays.contains(calendar.component(.weekday, from: now)) {
                    fireAlarm(alarm)
                    break
                }
            }
        }
    }

    func fireAlarm(_ alarm: Alarm) {
        firingAlarm = alarm
        isAlarmFiring = true
        playAlarmSound(alarm.sound)

        // Auto-stop if configured
        if case .automatic(let seconds) = alarm.stopMode {
            autoStopTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.stopAlarm()
                }
            }
        }

        // Disable one-shot alarms
        if alarm.repeatDays.isEmpty {
            if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
                alarms[index].isEnabled = false
                saveAlarms()
            }
        }
    }

    func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
        autoStopTimer?.invalidate()
        autoStopTimer = nil
        isAlarmFiring = false
        firingAlarm = nil

        // Deactivate our audio session so other apps (e.g. music) can resume
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    func snoozeAlarm(minutes: Int = 5) {
        guard let alarm = firingAlarm else { return }
        stopAlarm()

        // Schedule a new one-shot alarm for snooze
        let calendar = Calendar.current
        let snoozeDate = calendar.date(byAdding: .minute, value: minutes, to: Date())!
        var snoozed = alarm
        snoozed.id = UUID()
        snoozed.hour = calendar.component(.hour, from: snoozeDate)
        snoozed.minute = calendar.component(.minute, from: snoozeDate)
        snoozed.repeatDays = []
        snoozed.label = "\(alarm.label) (Snooze)"
        addAlarm(snoozed)
    }

    // MARK: - Sound

    private func playAlarmSound(_ sound: AlarmSound = .pulse) {
        configureAudioSession()

        // Try to load custom tone, fall back to generated sound
        if let url = Bundle.main.url(forResource: "alarm_tone", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
                return
            } catch {
                print("Failed to play custom tone: \(error)")
            }
        }

        playGeneratedTone(sound: sound)
    }

    private func configureAudioSession() {
        do {
            // .playback category overrides the silent/mute switch, matching
            // the built-in iOS Clock alarm behaviour.  Omitting .mixWithOthers
            // ensures the system treats this as primary audio so the mute
            // switch is ignored.  .duckOthers lowers other audio (e.g. music)
            // while the alarm rings rather than cutting it off entirely.
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(
                true,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            print("Audio session error: \(error)")
        }
    }

    private func playGeneratedTone(sound: AlarmSound = .pulse, duration: Double = 2.0, loop: Bool = true) {
        let sampleRate: Double = 44100
        let frequency = sound.frequency
        let beepDuration = sound.beepDuration
        let cycleDuration = beepDuration + sound.silenceDuration
        let numSamples = Int(sampleRate * duration)

        var audioData = Data()

        // WAV header
        let dataSize = UInt32(numSamples * 2)
        let fileSize = UInt32(36 + dataSize)

        audioData.append(contentsOf: "RIFF".utf8)
        audioData.append(contentsOf: withUnsafeBytes(of: fileSize.littleEndian) { Array($0) })
        audioData.append(contentsOf: "WAVE".utf8)
        audioData.append(contentsOf: "fmt ".utf8)
        audioData.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        audioData.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })
        audioData.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })
        audioData.append(contentsOf: withUnsafeBytes(of: UInt32(44100).littleEndian) { Array($0) })
        audioData.append(contentsOf: withUnsafeBytes(of: UInt32(88200).littleEndian) { Array($0) })
        audioData.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Array($0) })
        audioData.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Array($0) })
        audioData.append(contentsOf: "data".utf8)
        audioData.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })

        for i in 0..<numSamples {
            let time = Double(i) / sampleRate
            let cyclePosition = time.truncatingRemainder(dividingBy: cycleDuration)
            let isBeep = cyclePosition < beepDuration

            let amplitude: Double = isBeep ? 0.9 : 0.0
            let sample = Int16(amplitude * sin(2.0 * .pi * frequency * time) * Double(Int16.max))
            audioData.append(contentsOf: withUnsafeBytes(of: sample.littleEndian) { Array($0) })
        }

        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.numberOfLoops = loop ? -1 : 0
            audioPlayer?.play()
        } catch {
            print("Failed to play generated tone: \(error)")
        }
    }

    // MARK: - Sound Preview

    func previewSound(_ sound: AlarmSound) {
        stopPreview()
        configureAudioSession()
        playGeneratedTone(sound: sound, duration: 3.0, loop: false)
    }

    func stopPreview() {
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}
