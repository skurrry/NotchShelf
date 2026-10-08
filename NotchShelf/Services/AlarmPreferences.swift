import Foundation

enum AlarmSoundChoice: String, CaseIterable, Identifiable {
    case gentle = "TimerAlarmGentle"
    case bright = "TimerAlarmBright"
    case classic = "TimerAlarmClassic"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle: return "Sanft"
        case .bright: return "Hell"
        case .classic: return "Klassisch"
        }
    }
}

enum AlarmPreferences {
    static var sound: AlarmSoundChoice {
        get {
            AlarmSoundChoice(
                rawValue: UserDefaults.standard.string(
                    forKey: "alarm.sound"
                ) ?? ""
            ) ?? .classic
        }
        set {
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: "alarm.sound"
            )
        }
    }
}
