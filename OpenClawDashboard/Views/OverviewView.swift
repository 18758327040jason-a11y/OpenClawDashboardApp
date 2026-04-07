import SwiftUI

struct OverviewView: View {
    @ObservedObject private var gatewayService = GatewayService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 20) {
                    statusCard(title: "Gateway Status", value: gatewayStatusText, color: gatewayStatusColor)
                    statusCard(title: "Sessions", value: "\(gatewayService.sessions.count)", color: .blue)
                    statusCard(title: "Messages", value: "\(gatewayService.messages.count)", color: .green)
                }

                HStack(spacing: 20) {
                    statusCard(title: "Channels", value: "\(gatewayService.channels.count)", color: .orange)
                    statusCard(title: "System", value: gatewayService.systemStatus, color: .purple)
                    statusCard(title: "Version", value: "2026.3.13", color: .gray)
                }

                HStack(spacing: 20) {
                    statusCard(title: "Context %", value: "\(gatewayService.contextPercent)%", color: .teal)
                    statusCard(title: "Active Sessions", value: activeSessionsCount, color: .indigo)
                    statusCard(title: "Gateway", value: gatewayStatusText, color: gatewayStatusColor)
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            gatewayService.fetchSessions()
            gatewayService.fetchChannels()
        }
    }

    private var gatewayStatusText: String {
        switch gatewayService.connectionState {
        case .connected: return "Online"
        case .connecting: return "Connecting..."
        case .disconnected: return "Offline"
        case .error: return "Error"
        }
    }

    private var gatewayStatusColor: Color {
        switch gatewayService.connectionState {
        case .connected: return .green
        case .connecting: return .yellow
        case .disconnected: return .gray
        case .error: return .red
        }
    }

    private var activeSessionsCount: String {
        let today = Calendar.current.startOfDay(for: Date())
        let active = gatewayService.sessions.filter { $0.updatedAt >= today }
        return "\(active.count)"
    }

    private func statusCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Spacer()
        }
        .padding(16)
        .frame(minWidth: 150, minHeight: 100)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
}
