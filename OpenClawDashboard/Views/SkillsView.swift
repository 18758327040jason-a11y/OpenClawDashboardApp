import SwiftUI

struct SkillsView: View {
    @State private var skills: [String] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                ProgressView("Loading skills...")
            } else if skills.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "puzzlepiece.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No skills found")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(skills, id: \.self) { skill in
                            skillRow(skill)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func skillRow(_ skill: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "puzzlepiece.fill")
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 40)

            Text(skill)
                .font(.system(size: 14))

            Spacer()
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
}
