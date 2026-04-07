import SwiftUI

struct ModelPickerView: View {
    @Binding var selectedModel: String

    private let models = [
        "Default (MiniMax-M2.7)",
        "MiniMax-M2.5",
        "mimo-v2-flash"
    ]

    var body: some View {
        Picker("", selection: $selectedModel) {
            ForEach(models, id: \.self) { model in
                Text(model).tag(model)
            }
        }
        .pickerStyle(.menu)
        .frame(width: 160)
    }
}
