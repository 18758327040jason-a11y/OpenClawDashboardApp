import SwiftUI

enum NavigationSection: String, CaseIterable, Identifiable {
    case chat = "Chat"
    case control = "Control"
    case agent = "Agent"
    case settings = "Settings"
    var id: String { rawValue }
}

enum NavigationItem: Hashable, Identifiable {
    case chat
    case overview, channels, instances, sessions, usage, cronJobs
    case agents, skills, nodes
    case config, communications, appearance, automation, infrastructure, aiAgents, debug, logs

    var id: String {
        switch self {
        case .chat: return "chat"
        case .overview: return "overview"
        case .channels: return "channels"
        case .instances: return "instances"
        case .sessions: return "sessions"
        case .usage: return "usage"
        case .cronJobs: return "cronJobs"
        case .agents: return "agents"
        case .skills: return "skills"
        case .nodes: return "nodes"
        case .config: return "config"
        case .communications: return "communications"
        case .appearance: return "appearance"
        case .automation: return "automation"
        case .infrastructure: return "infrastructure"
        case .aiAgents: return "aiAgents"
        case .debug: return "debug"
        case .logs: return "logs"
        }
    }

    var label: String {
        switch self {
        case .chat: return "Chat"
        case .overview: return "Overview"
        case .channels: return "Channels"
        case .instances: return "Instances"
        case .sessions: return "Sessions"
        case .usage: return "Usage"
        case .cronJobs: return "Cron Jobs"
        case .agents: return "Agents"
        case .skills: return "Skills"
        case .nodes: return "Nodes"
        case .config: return "Config"
        case .communications: return "Communications"
        case .appearance: return "Appearance"
        case .automation: return "Automation"
        case .infrastructure: return "Infrastructure"
        case .aiAgents: return "AI & Agents"
        case .debug: return "Debug"
        case .logs: return "Logs"
        }
    }

    var iconName: String {
        switch self {
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .overview: return "gauge.with.dots.needle.33percent"
        case .channels: return "tv.fill"
        case .instances: return "server.rack"
        case .sessions: return "list.bullet.rectangle"
        case .usage: return "chart.bar.fill"
        case .cronJobs: return "clock.fill"
        case .agents: return "person.2.fill"
        case .skills: return "puzzlepiece.fill"
        case .nodes: return "network"
        case .config: return "gearshape.fill"
        case .communications: return "envelope.fill"
        case .appearance: return "paintbrush.fill"
        case .automation: return "bolt.fill"
        case .infrastructure: return "internaldrive.fill"
        case .aiAgents: return "brain.head.profile"
        case .debug: return "ant.fill"
        case .logs: return "doc.text.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedSection: NavigationSection = .chat
    @State private var selectedItem: NavigationItem = .chat
    @State private var isSidebarCollapsed = false
    @State private var isFocusMode = false

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if !isFocusMode && !isSidebarCollapsed {
                    SidebarView(
                        selectedSection: $selectedSection,
                        selectedItem: $selectedItem,
                        isCollapsed: $isSidebarCollapsed
                    )
                    .frame(width: 220)
                    .transition(.move(edge: .leading))
                }

                Divider()

                mainContent
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 800, minHeight: 500)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            if !isFocusMode {
                pageHeader
            }
            Divider()
            pageContent
        }
    }

    @ViewBuilder
    private var pageHeader: some View {
        HStack(spacing: 12) {
            if isSidebarCollapsed {
                Button {
                    withAnimation { isSidebarCollapsed = false }
                } label: {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)
            }

            Text(selectedItem.label)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button {
                withAnimation { isFocusMode.toggle() }
            } label: {
                Image(systemName: isFocusMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.borderless)
            .help("Toggle Focus Mode")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var pageContent: some View {
        switch selectedItem {
        case .chat:
            ChatView()
        case .overview:
            OverviewView()
        case .channels:
            ChannelsView()
        case .sessions:
            SessionsView()
        case .skills:
            SkillsView()
        case .appearance, .config, .communications, .automation, .infrastructure, .aiAgents, .debug, .logs:
            SettingsView(selectedItem: selectedItem)
        default:
            PlaceholderView(title: selectedItem.label)
        }
    }
}

struct PlaceholderView: View {
    let title: String
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("\(title) — Coming Soon")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
