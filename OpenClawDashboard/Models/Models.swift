import Foundation

// MARK: - Message Model
struct Message: Identifiable, Codable, Equatable {
    let id: String
    let role: String
    let sender: String
    let content: String
    let timestamp: Date
    var model: String?
    var tokenString: String?
    var toolOutput: [ToolOutput]?

    struct ToolOutput: Identifiable, Codable, Equatable {
        var id: String { toolName }
        let toolName: String
        let output: String
    }

    var avatarName: String {
        switch role {
        case "user": return "person.fill"
        case "assistant": return "puzzlepiece.fill"
        case "system": return "gearshape.fill"
        default: return "bubble.left.fill"
        }
    }

    var avatarColor: String {
        switch role {
        case "user": return "blue"
        case "assistant": return "green"
        case "system": return "orange"
        default: return "gray"
        }
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Session Model
struct Session: Identifiable, Codable {
    let id: String
    let sessionKey: String
    let updatedAt: Date
    let messageCount: Int
    var inputTokens: Int?
    var outputTokens: Int?
    var status: String?
    var model: String?

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: updatedAt)
    }
}

// MARK: - Channel Model
struct Channel: Identifiable, Codable {
    let id: String
    let name: String
    let type: String
    var status: String?
    var botName: String?
    var messageCount: Int?
}

// MARK: - Model Info
struct ModelInfo: Identifiable {
    let id: String
    let name: String
    let isDefault: Bool

    static let all: [ModelInfo] = [
        ModelInfo(id: "default", name: "Default (MiniMax-M2.7)", isDefault: true),
        ModelInfo(id: "minimax-m2.5", name: "MiniMax-M2.5", isDefault: false),
        ModelInfo(id: "mimo-v2-flash", name: "mimo-v2-flash", isDefault: false)
    ]
}
