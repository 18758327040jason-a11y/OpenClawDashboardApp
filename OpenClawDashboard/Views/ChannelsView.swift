import SwiftUI

struct ChannelsView: View {
    @ObservedObject private var gatewayService = GatewayService.shared

    var body: some View {
        ScrollView {
            if gatewayService.channels.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tv.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No channels found")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Button("Refresh") {
                        gatewayService.fetchChannels()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(gatewayService.channels) { channel in
                        channelRow(channel)
                    }
                }
                .padding(24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            gatewayService.fetchChannels()
        }
    }

    private func channelRow(_ channel: Channel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "tv.fill")
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(channel.name)
                    .font(.system(size: 14, weight: .medium))
                Text(channel.type.capitalized)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let botName = channel.botName {
                Text(botName)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(4)
            }

            Text(channel.status ?? "Unknown")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(4)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
}
