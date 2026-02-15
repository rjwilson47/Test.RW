import Foundation

enum AlarmSound: String, Codable, CaseIterable, Equatable {
    case pulse = "Pulse"
    case anchor = "Anchor"
    case sparkle = "Sparkle"
    case surge = "Surge"
    case standard = "Standard"
    case soft = "Soft"

    var frequency: Double {
        switch self {
        case .pulse: return 880.0      // A5
        case .anchor: return 523.25    // C5
        case .sparkle: return 1046.5   // C6
        case .surge: return 659.25     // E5
        case .standard: return 440.0   // A4
        case .soft: return 392.0       // G4
        }
    }

    var beepDuration: Double {
        switch self {
        case .pulse: return 0.3
        case .anchor: return 0.5
        case .sparkle: return 0.15
        case .surge: return 0.4
        case .standard: return 0.25
        case .soft: return 0.6
        }
    }

    var silenceDuration: Double {
        switch self {
        case .pulse: return 0.2
        case .anchor: return 0.3
        case .sparkle: return 0.35
        case .surge: return 0.1
        case .standard: return 0.25
        case .soft: return 0.8
        }
    }

    var iconName: String {
        switch self {
        case .pulse: return "antenna.radiowaves.left.and.right"
        case .anchor: return "light.beacon.max"
        case .sparkle: return "bell"
        case .surge: return "waveform"
        case .standard: return "alarm"
        case .soft: return "leaf"
        }
    }
}

enum AlarmStopMode: Codable, Equatable {
    case manual
    case automatic(seconds: Int)

    var label: String {
        switch self {
        case .manual:
            return "Until turned off"
        case .automatic(let seconds):
            return "Auto-stop after \(seconds)s"
        }
    }

    var isAutomatic: Bool {
        if case .automatic = self { return true }
        return false
    }

    var seconds: Int {
        switch self {
        case .manual: return 0
        case .automatic(let s): return s
        }
    }
}

struct Alarm: Identifiable, Codable, Equatable {
    var id: UUID
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var label: String
    var stopMode: AlarmStopMode
    var repeatDays: Set<Int> // 1=Sun, 2=Mon, ..., 7=Sat; empty = one-shot
    var snoozeEnabled: Bool
    var sound: AlarmSound

    var timeString: String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return String(format: "%d:%02d %@", h, minute, ampm)
    }

    var nextFireDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = 0

        if repeatDays.isEmpty {
            // One-shot: find next occurrence of this time
            guard let candidate = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) else {
                return nil
            }
            return candidate
        } else {
            // Repeating: find next matching weekday
            var nearest: Date?
            for weekday in repeatDays {
                var dayComponents = components
                dayComponents.weekday = weekday
                if let candidate = calendar.nextDate(after: now, matching: dayComponents, matchingPolicy: .nextTime) {
                    if nearest == nil || candidate < nearest! {
                        nearest = candidate
                    }
                }
            }
            return nearest
        }
    }

    init(
        id: UUID = UUID(),
        hour: Int = 8,
        minute: Int = 0,
        isEnabled: Bool = true,
        label: String = "Alarm",
        stopMode: AlarmStopMode = .manual,
        repeatDays: Set<Int> = [],
        snoozeEnabled: Bool = true,
        sound: AlarmSound = .pulse
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.label = label
        self.stopMode = stopMode
        self.repeatDays = repeatDays
        self.snoozeEnabled = snoozeEnabled
        self.sound = sound
    }
}
