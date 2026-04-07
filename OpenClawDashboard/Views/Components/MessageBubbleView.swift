import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let showThinking: Bool
    let onReadAloud: () -> Void
    let onDelete: () -> Void

    @State private var isExpanded = true

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: message.avatarName)
                .font(.system(size: 20))
                .foregroundColor(avatarColor)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                headerRow
                if isExpanded {
                    Text(message.content)
                        .font(.system(size: 13))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if showThinking, let toolOutputs = message.toolOutput, !toolOutputs.isEmpty {
                        ForEach(toolOutputs) { tool in
                            toolOutputBlock(tool)
                        }
                    }
                }
                actionButtons
            }
        }
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(10)
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text(message.sender.capitalized)
                .font(.system(size: 12, weight: .semibold))
            Text(message.formattedTime)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            if (message.tokenString ?? "").isEmpty {
                Text(message.tokenString ?? "")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            if let model = message.model {
                Text(model)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(3)
            }
            Spacer()
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                onReadAloud()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Read aloud")
                }
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)

            Button {
                onDelete()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .font(.system(size: 10))
                .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(.plain)

            if (message.toolOutput?.count ?? 0) > 0 {
                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    Text(isExpanded ? "Collapse" : "Expand")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 4)
    }

    private func toolOutputBlock(_ tool: Message.ToolOutput) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "puzzlepiece.fill")
                    .font(.system(size: 10))
                Text(tool.toolName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            Text(tool.output)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .lineLimit(5)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(6)
    }

    private var avatarColor: Color {
        switch message.avatarColor {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        default: return .gray
        }
    }

    private var backgroundColor: Color {
        switch message.role {
        case "user":
            return Color.blue.opacity(0.08)
        case "assistant":
            return Color(nsColor: .controlBackgroundColor)
        default:
            return Color(nsColor: .controlBackgroundColor)
        }
    }
}
