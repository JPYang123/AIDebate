import SwiftUI

struct ExportView: View {
    let text: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(text)
                    .font(.system(size: 12))
                    .monospaced()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Export Debate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: text, preview: SharePreview("Debate Transcript")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
