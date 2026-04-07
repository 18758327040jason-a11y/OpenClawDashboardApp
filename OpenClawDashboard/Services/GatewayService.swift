import Foundation
import Combine

enum GatewayConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)
}

@MainActor
class GatewayService: ObservableObject {
    static let shared = GatewayService()

    @Published var connectionState: GatewayConnectionState = .disconnected
    @Published var messages: [Message] = []
    @Published var sessions: [Session] = []
    @Published var channels: [Channel] = []
    @Published var systemStatus: String = "Unknown"
    @Published var contextPercent: Int = 0

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var pingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupURLSession()
    }

    private func setupURLSession() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        urlSession = URLSession(configuration: config)
    }

    func connect() {
        guard let token = ConfigService.shared.gatewayToken else {
            connectionState = .error("No token found")
            return
        }
        guard let url = URL(string: ConfigService.shared.gatewayURL) else {
            connectionState = .error("Invalid gateway URL")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        connectionState = .connecting
        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()
        connectionState = .connected
        startPinging()
        Task {
            await receiveMessages()
        }
    }

    func disconnect() {
        pingTimer?.invalidate()
        pingTimer = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
    }

    private func startPinging() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendPing()
            }
        }
    }

    private func sendPing() {
        let ping = ["jsonrpc": "2.0", "id": UUID().uuidString, "method": "ping", "params": [:]] as [String: Any]
        sendRPC(ping)
    }

    private func sendRPC(_ request: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: request),
              let string = String(data: data, encoding: .utf8) else { return }
        webSocketTask?.send(.string(string)) { _ in }
    }

    private func receiveMessages() async {
        guard let task = webSocketTask else { return }
        do {
            while connectionState == .connected {
                let message = try await task.receive()
                switch message {
                case .string(let text):
                    await handleTextMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        await handleTextMessage(text)
                    }
                @unknown default:
                    break
                }
            }
        } catch {
            connectionState = .error(error.localizedDescription)
        }
    }

    private func handleTextMessage(_ text: String) async {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let method = json["method"] as? String,
              let result = json["result"] as? [String: Any] else { return }
        await handleRPCResponse(method: method, result: result)
    }

    private func handleRPCResponse(method: String, result: [String: Any]) async {
        switch method {
        case "chat.history":
            if let msgs = result["messages"] as? [[String: Any]] {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = try? JSONSerialization.data(withJSONObject: msgs),
                   let msgs = try? decoder.decode([Message].self, from: data) {
                    messages = msgs
                }
            }
        case "session.list":
            if let sess = result["sessions"] as? [[String: Any]] {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = try? JSONSerialization.data(withJSONObject: sess),
                   let sess = try? decoder.decode([Session].self, from: data) {
                    sessions = sess
                }
            }
        case "channel.list":
            if let chans = result["channels"] as? [[String: Any]] {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = try? JSONSerialization.data(withJSONObject: chans),
                   let chans = try? decoder.decode([Channel].self, from: data) {
                    channels = chans
                }
            }
        case "system.status":
            if let status = result["status"] as? String {
                systemStatus = status
            }
        default:
            break
        }
    }

    func fetchChatHistory() {
        sendRPC(["jsonrpc": "2.0", "id": UUID().uuidString, "method": "chat.history", "params": ["limit": 50]])
    }

    func fetchSessions() {
        sendRPC(["jsonrpc": "2.0", "id": UUID().uuidString, "method": "session.list", "params": [:]])
    }

    func fetchChannels() {
        sendRPC(["jsonrpc": "2.0", "id": UUID().uuidString, "method": "channel.list", "params": [:]])
    }

    func sendChatMessage(_ content: String, model: String?) async {
        var params: [String: Any] = ["content": content]
        if let model = model {
            params["model"] = model
        }
        sendRPC(["jsonrpc": "2.0", "id": UUID().uuidString, "method": "chat.send", "params": params])
    }

    func deleteMessage(_ messageId: String) {
        messages.removeAll { $0.id == messageId }
        sendRPC(["jsonrpc": "2.0", "id": UUID().uuidString, "method": "chat.delete", "params": ["messageId": messageId]])
    }
}
