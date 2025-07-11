import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: DebateViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // Voice Selection Section
                Section(header: Text("Voice Selection (OpenAI TTS)")) {
                    Picker("Voice", selection: $viewModel.selectedVoice) {
                        ForEach(viewModel.availableVoices, id: \.self) { voice in
                            Text(voice.capitalized).tag(voice)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Language Selection Section
                Section(header: Text("Debate Language")) {
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.availableLanguages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("API Keys")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("OpenAI API Key")
                            .font(.headline)
                        SecureField("Enter OpenAI API Key", text: $viewModel.openAIKey)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Claude API Key")
                             .font(.headline)
                        SecureField("Enter Claude API Key", text: $viewModel.claudeKey)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Gemini API Key")
                            .font(.headline)
                        SecureField("Enter Gemini API Key", text: $viewModel.geminiKey)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Deepseek API Key")
                             .font(.headline)
                        SecureField("Enter Deepseek API Key", text: $viewModel.deepseekKey)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Groq API Key")
                            .font(.headline)
                        SecureField("Enter Groq API Key", text: $viewModel.groqKey)
                    }
                }

                Section(header: Text("Information")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How to get API Keys:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("• OpenAI: platform.openai.com")
                            Text("• Claude: console.anthropic.com")
                            Text("• Gemini: aistudio.google.com")
                            Text("• Deepseek: platform.deepseek.com")
                            Text("• Groq: console.groq.com")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .onTapGesture {
                 hideKeyboard()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }
}
