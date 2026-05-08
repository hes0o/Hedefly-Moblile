import Foundation
import Observation

enum Mood: String, CaseIterable {
    case energetic = "energetic"
    case moderate  = "moderate"
    case tired     = "tired"

    var emoji: String {
        switch self {
        case .energetic: return "🚀"
        case .moderate:  return "😊"
        case .tired:     return "😴"
        }
    }

    var label: String {
        switch self {
        case .energetic: return "Energetic"
        case .moderate:  return "Moderate"
        case .tired:     return "Tired"
        }
    }

    var description: String {
        switch self {
        case .energetic: return "High energy tasks are ready for you"
        case .moderate:  return "A balanced mix of tasks for today"
        case .tired:     return "Light tasks — take it easy today"
        }
    }
}

@Observable
final class MoodManager {
    static let shared = MoodManager()
    private init() { restore() }

    var selectedMood: Mood? = nil
    var hasPickedToday: Bool = false

    private let moodKey     = "hedefly_mood"
    private let moodDateKey = "hedefly_mood_date"

    func selectMood(_ mood: Mood) {
        selectedMood = mood
        hasPickedToday = true
        UserDefaults.standard.set(mood.rawValue, forKey: moodKey)
        UserDefaults.standard.set(todayString, forKey: moodDateKey)
    }

    private func restore() {
        guard let savedDate = UserDefaults.standard.string(forKey: moodDateKey),
              savedDate == todayString,
              let raw = UserDefaults.standard.string(forKey: moodKey),
              let mood = Mood(rawValue: raw) else {
            return
        }
        selectedMood = mood
        hasPickedToday = true
    }

    private var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
