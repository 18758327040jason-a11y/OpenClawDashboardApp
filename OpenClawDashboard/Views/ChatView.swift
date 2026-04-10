import SwiftUI
import WebKit

// MARK: - KeyboardPassThroughWebView
class KeyboardPassThroughWebView: WKWebView {
    // 不强制抢 firstResponder，让 web 内容自然显示光标
    override var acceptsFirstResponder: Bool { false }

    // 拦截 Cmd+C/V/X/A，通过 JS 在 web 内容层执行
    override func keyDown(with event: NSEvent) {
        let cmd = event.modifierFlags.contains(.command)
        guard cmd else { super.keyDown(with: event); return }

        let key = event.charactersIgnoringModifiers?.lowercased() ?? ""
        let editKeys = ["c", "v", "x", "a"]

        guard editKeys.contains(key) else { super.keyDown(with: event); return }

        switch key {
        case "c": evaluateJavaScript("document.execCommand('copy')", completionHandler: nil)
        case "v": evaluateJavaScript(
            "navigator.clipboard.readText().then(t=>{document.execCommand('insertText',false,t)}).catch(()=>{})",
            completionHandler: nil)
        case "x": evaluateJavaScript("document.execCommand('cut')", completionHandler: nil)
        case "a": evaluateJavaScript("document.execCommand('selectAll')", completionHandler: nil)
        default: super.keyDown(with: event)
        }
    }
}

// MARK: - DashboardWebView
struct DashboardWebView: NSViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> KeyboardPassThroughWebView {
        let config = WKWebViewConfiguration()
        let webView = KeyboardPassThroughWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: KeyboardPassThroughWebView, context: Context) {}

    class Coordinator: NSObject {}
}

// MARK: - ChatView
struct ChatView: View {
    @State private var dashboardURL: URL? = nil

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
        if let token = token {
            dashboardURL = URL(string: "http://127.0.0.1:18789/#token=\(token)")
        } else {
            dashboardURL = URL(string: "http://127.0.0.1:18789/")
        }
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
