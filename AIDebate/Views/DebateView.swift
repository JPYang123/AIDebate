import SwiftUI

struct DebateView: View {
    @ObservedObject var viewModel: DebateViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingExport = false
    @State private var exportText = ""

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.white, .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message) { msg in
                                viewModel.speakMessage(msg)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Debate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        exportText = viewModel.exportDebate()
                        showingExport = true
                    }
                    .disabled(viewModel.messages.isEmpty)
                }
            }
            .onTapGesture { hideKeyboard() }
            .overlay(
                Group {
                    if viewModel.isConvertingSpeech {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Converting to Speech…")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(.regularMaterial)
                        .cornerRadius(12)
                    }
                }
            )
            .task {
                await viewModel.startDebate()
            }
        }
        .sheet(isPresented: $showingExport) {
            ExportView(text: exportText)
        }
    }
}

#if DEBUG
struct DebateView_Previews: PreviewProvider {
    static var previews: some View {
        DebateView(viewModel: DebateViewModel())
    }
}
#endif
