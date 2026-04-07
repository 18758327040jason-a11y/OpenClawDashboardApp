import SwiftUI

struct SettingsView: View {
    let selectedItem: NavigationItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(selectedItem.label)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Settings for \(selectedItem.label)")
                        .font(.headline)
                    Text("This section is under development.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(10)
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
