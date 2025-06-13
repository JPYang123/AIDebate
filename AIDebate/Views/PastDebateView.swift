import SwiftUI

struct PastDebatesView: View {
    @ObservedObject var viewModel: DebateViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedDebate: DebateRecord?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.pastDebates) { debate in
                    Button(action: { selectedDebate = debate }) {
                        VStack(alignment: .leading) {
                            Text(debate.topic)
                                .font(.headline)
                            Text(debate.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { viewModel.pastDebates[$0] }.forEach { viewModel.deleteDebate($0) }
                }
            }
            .navigationTitle("Past Debates")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(item: $selectedDebate) { debate in
                DebateHistoryDetailView(debate: debate, viewModel: viewModel)
            }
        }
    }
}

struct DebateHistoryDetailView: View {
    let debate: DebateRecord
    @ObservedObject var viewModel: DebateViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    ForEach(debate.messages.map { $0.toDebateMessage() }) { message in
                        MessageView(message: message) { msg in
                            viewModel.speakMessage(msg)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(debate.topic)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
