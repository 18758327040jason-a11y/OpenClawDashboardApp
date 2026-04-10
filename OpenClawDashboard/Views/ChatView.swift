import SwiftUI
import WebKit

// MARK: - KeyboardPassThroughWebView
class KeyboardPassThroughWebView: WKWebView {
    private var pasteMenuItem: NSMenuItem?

    override var acceptsFirstResponder: Bool { false }

    override func keyDown(with event: NSEvent) {
        let cmd = event.modifierFlags.contains(.command)
        guard cmd else { super.keyDown(with: event); return }
        let key = event.charactersIgnoringModifiers?.lowercased() ?? ""
        switch key {
        case "c": evaluateJavaScript("document.execCommand('copy')", completionHandler: nil)
        case "x": evaluateJavaScript("document.execCommand('cut')", completionHandler: nil)
        case "v":
            // 走系统剪贴板，不走 JS clipboard API，避免弹窗
            if let text = NSPasteboard.general.string(forType: .string), !text.isEmpty {
                let escaped = text
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "'", with: "\\'")
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\r", with: "\\r")
                evaluateJavaScript("document.execCommand('insertText',false,'\(escaped)')", completionHandler: nil)
            }
        case "a": evaluateJavaScript("document.execCommand('selectAll')", completionHandler: nil)
        case "z": evaluateJavaScript("document.execCommand('undo')", completionHandler: nil)
        case "y": evaluateJavaScript("document.execCommand('redo')", completionHandler: nil)
        default: super.keyDown(with: event)
        }
    }
}

// MARK: - DashboardWebView
struct DashboardWebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> KeyboardPassThroughWebView {
        let config = WKWebViewConfiguration()
        let webView = KeyboardPassThroughWebView(frame: .zero, configuration: config)
        
        // App 启动时预读剪贴板，提前触发 macOS 授权（如果尚未授权）
        DispatchQueue.main.async {
            let _ = NSPasteboard.general.string(forType: .string)
        }
        
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: KeyboardPassThroughWebView, context: Context) {}
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
