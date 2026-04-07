import SwiftUI
import WebKit

struct DashboardWebView: NSViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    class Coordinator: NSObject {}
}

struct ChatView: View {
    @State private var dashboardURL: URL? = nil
    @State private var isFocusMode: Bool = false

    var body: some View {
        Group {
            if let url = dashboardURL {
                DashboardWebView(url: url)
            } else {
                VStack(spacing: 16) {
                    ProgressView("Loading Dashboard...")
                    Text("Connecting to Gateway at 127.0.0.1:18789...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadDashboard()
        }
    }

    private func loadDashboard() {
        let token = getToken()
        let urlString: String
        if let token = token {
            urlString = "http://127.0.0.1:18789/#token=\(token)"
        } else {
            urlString = "http://127.0.0.1:18789/"
        }
        dashboardURL = URL(string: urlString)
    }

    private func getToken() -> String? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let path = home.appendingPathComponent(".openclaw/openclaw.json")
        guard let data = try? Data(contentsOf: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let gateway = json["gateway"] as? [String: Any],
              let auth = gateway["auth"] as? [String: Any],
              let token = auth["token"] as? String else {
            return nil
        }
        return token
    }
}
