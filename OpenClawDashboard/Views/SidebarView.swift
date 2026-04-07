import SwiftUI

struct SidebarView: View {
    @Binding var selectedSection: NavigationSection
    @Binding var selectedItem: NavigationItem
    @Binding var isCollapsed: Bool
    @ObservedObject private var gatewayService = GatewayService.shared

    @State private var expandedSections: Set<NavigationSection> = [.chat, .control, .agent, .settings]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    sectionGroup(section: .chat, items: [.chat])
                    if expandedSections.contains(.control) {
                        sectionGroup(section: .control, items: [.overview, .channels, .instances, .sessions, .usage, .cronJobs])
                    }
                    if expandedSections.contains(.agent) {
                        sectionGroup(section: .agent, items: [.agents, .skills, .nodes])
                    }
                    if expandedSections.contains(.settings) {
                        sectionGroup(section: .settings, items: [.config, .communications, .appearance, .automation, .infrastructure, .aiAgents, .debug, .logs])
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            Spacer()
            Divider()
            footerSection
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var headerSection: some View {
        HStack(spacing: 8) {
            Text("🦀")
                .font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text("OpenClaw Gateway")
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
            }
            Spacer()
            Button {
                withAnimation { isCollapsed = true }
            } label: {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 12))
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func sectionGroup(section: NavigationSection, items: [NavigationItem]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Button {
                withAnimation {
                    if expandedSections.contains(section) {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    sectionIcon(for: section)
                    Text(section.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: expandedSections.contains(section) ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            if expandedSections.contains(section) {
                ForEach(items) { item in
                    sidebarItem(for: item)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionIcon(for section: NavigationSection) -> some View {
        switch section {
        case .chat:
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 10))
                .foregroundColor(.accentColor)
        case .control:
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 10))
                .foregroundColor(.accentColor)
        case .agent:
            Image(systemName: "brain.head.profile")
                .font(.system(size: 10))
                .foregroundColor(.accentColor)
        case .settings:
            Image(systemName: "gearshape.fill")
                .font(.system(size: 10))
                .foregroundColor(.accentColor)
        }
    }

    private func sidebarItem(for item: NavigationItem) -> some View {
        Button {
            selectedSection = sectionFor(item)
            selectedItem = item
        } label: {
            HStack(spacing: 8) {
                Image(systemName: item.iconName)
                    .font(.system(size: 12))
                    .frame(width: 16)
                Text(item.label)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedItem == item ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .foregroundColor(selectedItem == item ? .primary : .secondary)
    }

    private func sectionFor(_ item: NavigationItem) -> NavigationSection {
        switch item {
        case .chat: return .chat
        case .overview, .channels, .instances, .sessions, .usage, .cronJobs: return .control
        case .agents, .skills, .nodes: return .agent
        case .config, .communications, .appearance, .automation, .infrastructure, .aiAgents, .debug, .logs: return .settings
        }
    }

    private var footerSection: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Link(destination: URL(string: "https://docs.openclaw.com")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 11))
                        Text("Docs")
                            .font(.system(size: 11))
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Spacer()
                Text("v2026.3.13")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(connectionColor)
                    .frame(width: 7, height: 7)
                Text(connectionLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var connectionColor: Color {
        switch gatewayService.connectionState {
        case .connected: return .green
        case .connecting: return .yellow
        case .disconnected: return .gray
        case .error: return .red
        }
    }

    private var connectionLabel: String {
        switch gatewayService.connectionState {
        case .connected: return "Gateway: Online"
        case .connecting: return "Gateway: Connecting..."
        case .disconnected: return "Gateway: Offline"
        case .error(let msg): return "Gateway: \(msg)"
        }
    }
}
