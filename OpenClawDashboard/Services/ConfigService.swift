import Foundation

class ConfigService {
    static let shared = ConfigService()
    private init() {}

    var gatewayToken: String? {
        guard let path = getConfigPath() else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(OpenClawConfig.self, from: data) else {
            return nil
        }
        return config.gateway?.auth?.token
    }

    var gatewayURL: String {
        return "ws://127.0.0.1:18789"
    }

    var dashboardBaseURL: String {
        return "http://127.0.0.1:18789"
    }

    var dashboardURL: String {
        if let token = gatewayToken {
            return "\(dashboardBaseURL)/#token=\(token)"
        }
        return dashboardBaseURL
    }

    private func getConfigPath() -> String? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let path = home.appendingPathComponent(".openclaw/openclaw.json")
        if FileManager.default.fileExists(atPath: path.path) {
            return path.path
        }
        return nil
    }
}

struct OpenClawConfig: Codable {
    let gateway: GatewayConfig?

    struct GatewayConfig: Codable {
        let auth: AuthConfig?
        struct AuthConfig: Codable {
            let token: String?
        }
    }
}
