import SwiftUI

struct SessionsView: View {
    @ObservedObject private var gatewayService = GatewayService.shared

    var body: some View {
        ScrollView {
            if gatewayService.sessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No sessions found")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Button("Refresh") {
                        gatewayService.fetchSessions()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(gatewayService.sessions) { session in
                        sessionRow(session)
                    }
                }
                .padding(24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            gatewayService.fetchSessions()
        }
    }

    private func sessionRow(_ session: Session) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.sessionKey)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                Text(session.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.messageCount) msgs")
                    .font(.system(size: 11))
                if let status = session.status {
                    Text(status)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                if let model = session.model {
                    Text(model)
                        .font(.system(size: 10))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
}
