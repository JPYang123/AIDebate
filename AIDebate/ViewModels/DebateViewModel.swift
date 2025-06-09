import Foundation

//  MARK: - ViewModel
@MainActor
class DebateViewModel: ObservableObject {
    @Published var topic = ""
    @Published var selectedAffirmativeModel = 0
    @Published var selectedOppositionModel = 1
    @Published var numberOfRounds = 2
    @Published var messages: [DebateMessage] = []
    @Published var isDebating = false
    @Published var isResearching = false
    @Published var isConvertingSpeech = false

    // API Keys
    @Published var openAIKey = ""
    @Published var claudeKey = ""
    @Published var geminiKey = ""
    @Published var deepseekKey = ""
    @Published var groqKey = ""

    // Voice and Language Selection
    @Published var selectedVoice: String = "nova"
    @Published var selectedLanguage: String = "English"

    private let aiService: AIServiceProtocol
    private let researchService: ResearchService
    private let ttsService = TextToSpeechService()

    // Lists for UI Pickers
    let availableVoices = ["alloy", "ash", "ballad", "coral", "echo", "fable", "nova", "onyx", "sage", "shimmer"]
    let availableLanguages = ["English", "Spanish", "French", "German", "Italian", "Japanese", "Chinese", "Korean", "Portuguese"]

    let availableModels: [AIModel] = [
        AIModel(name: "GPT-4o", modelId: "gpt-4o", type: .openai, baseURL: "https://api.openai.com"),
        AIModel(name: "GPT-4o-mini", modelId: "gpt-4o-mini", type: .openai, baseURL: "https://api.openai.com"),
        AIModel(name: "Claude 3.7 Sonnet", modelId: "claude-3-7-sonnet-latest", type: .claude, baseURL: nil),
        AIModel(name: "Gemini-2.0-Flash", modelId: "gemini-2.0-flash", type: .gemini, baseURL: nil),
        AIModel(name: "Deepseek-Chat", modelId: "deepseek-chat", type: .deepseek, baseURL: "https://api.deepseek.com"),
        AIModel(name: "Llama-3.3-70b-versatile (Groq)", modelId: "llama-3.3-70b-versatile", type: .groq, baseURL: "https://api.groq.com/openai")
    ]

    var availableModelNames: [String] {
        availableModels.map { $0.name }
    }

    init(aiService: AIServiceProtocol = AIService(), researchService: ResearchService = ResearchService()) {
        self.aiService = aiService
        self.researchService = researchService
        loadSettings()
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard
        openAIKey = defaults.string(forKey: "openai_key") ?? ""
        claudeKey = defaults.string(forKey: "claude_key") ?? ""
        geminiKey = defaults.string(forKey: "gemini_key") ?? ""
        deepseekKey = defaults.string(forKey: "deepseek_key") ?? ""
        groqKey = defaults.string(forKey: "groq_key") ?? ""
        selectedVoice = defaults.string(forKey: "selected_voice") ?? "nova"
        selectedLanguage = defaults.string(forKey: "selected_language") ?? "English"
    }

    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(openAIKey, forKey: "openai_key")
        defaults.set(claudeKey, forKey: "claude_key")
        defaults.set(geminiKey, forKey: "gemini_key")
        defaults.set(deepseekKey, forKey: "deepseek_key")
        defaults.set(groqKey, forKey: "groq_key")
        defaults.set(selectedVoice, forKey: "selected_voice")
        defaults.set(selectedLanguage, forKey: "selected_language")
    }

    private func getAPIKey(for model: AIModel) -> String {
        switch model.type {
        case .openai:
            return openAIKey
        case .claude:
            return claudeKey
        case .gemini:
            return geminiKey
        case .deepseek:
            return deepseekKey
        case .groq:
            return groqKey
        }
    }

    func startDebate() async {
        guard !topic.isEmpty else { return }

        isDebating = true
        isResearching = true
        messages.removeAll()

        addMessage(speaker: nil, content: " 🔍 Conducting research...", isSystem: true)

        do {
            let research = try await researchService.conductResearch(topic: topic, apiKey: geminiKey)

            messages.removeLast()
            addMessage(speaker: nil, content: "### Affirmative Research Briefing\n\n---\n\(research.affirmativeArguments)", isSystem: true)
            addMessage(speaker: nil, content: "### Opposition Research Briefing\n\n---\n\(research.oppositionArguments)", isSystem: true)
            addMessage(speaker: nil, content: " ✅ Research complete. The debate will now begin.", isSystem: true)

            isResearching = false

            await conductDebate(research: research)

        } catch {
            isResearching = false
            addMessage(speaker: nil, content: " ❌ Research failed: \(error.localizedDescription)", isSystem: true)
        }

        isDebating = false
        addMessage(speaker: nil, content: " 🏁 Debate finished.", isSystem: true)
    }

    private func conductDebate(research: ResearchBriefing) async {
        let affModel = availableModels[selectedAffirmativeModel]
        let oppModel = availableModels[selectedOppositionModel]

        let affSystemPrompt = """
        You are a world-class debater arguing IN FAVOR of the topic: \(topic).
        ## Research Briefing (Arguments FOR your stance)
        <research>
        \(research.affirmativeArguments)
        </research>

        Your opening statement should use this research.
        In subsequent turns, counter your opponent's arguments directly while reinforcing your own. Provide your response in \(selectedLanguage).
        """

        let oppSystemPrompt = """
        You are a world-class debater arguing AGAINST the topic: \(topic).
        ## Research Briefing (Arguments AGAINST your stance)
        <research>
        \(research.oppositionArguments)
        </research>

        Your opening statement should use this research.
        In subsequent turns, counter your opponent's arguments directly while reinforcing your own. Provide your response in \(selectedLanguage).
        """

        var affMessages: [ChatMessage] = []
        var oppMessages: [ChatMessage] = []

        for round in 1...numberOfRounds {
            // Affirmative turn
            await generateResponse(
                model: affModel,
                systemPrompt: affSystemPrompt,
                conversationHistory: buildConversationHistory(affMessages: affMessages, oppMessages: oppMessages, isAffirmative: true),
                speaker: "Affirmative (\(affModel.name))",
                isAffirmative: true
            ) { response in
                affMessages.append(ChatMessage(role: "assistant", content: response))
            }

            // Opposition turn
            await generateResponse(
                model: oppModel,
                systemPrompt: oppSystemPrompt,
                conversationHistory: buildConversationHistory(affMessages: affMessages, oppMessages: oppMessages, isAffirmative: false),
                speaker: "Opposition (\(oppModel.name))",
                isAffirmative: false
            ) { response in
                oppMessages.append(ChatMessage(role: "assistant", content: response))
            }
        }
    }

    private func buildConversationHistory(affMessages: [ChatMessage], oppMessages: [ChatMessage], isAffirmative: Bool) -> [ChatMessage] {
        var history: [ChatMessage] = []

        let maxCount = max(affMessages.count, oppMessages.count)

        for i in 0..<maxCount {
            if isAffirmative {
                if i < oppMessages.count {
                    history.append(ChatMessage(role: "user", content: oppMessages[i].content))
                }
                if i < affMessages.count {
                    history.append(ChatMessage(role: "assistant", content: affMessages[i].content))
                }
            } else {
                if i < affMessages.count {
                    history.append(ChatMessage(role: "user", content: affMessages[i].content))
                }
                if i < oppMessages.count {
                    history.append(ChatMessage(role: "assistant", content: oppMessages[i].content))
                }
            }
        }

        return history
    }

    private func generateResponse(
        model: AIModel,
        systemPrompt: String,
        conversationHistory: [ChatMessage],
        speaker: String,
        isAffirmative: Bool,
        completion: @escaping (String) -> Void
    ) async {
        let apiKey = getAPIKey(for: model)

        guard !apiKey.isEmpty else {
            addMessage(speaker: speaker, content: " ❌ API key not configured for \(model.name)", isSystem: false)
            return
        }

        let messageIndex = messages.count
        addMessage(speaker: speaker, content: "", isSystem: false)

        var fullResponse = ""

        do {
            let stream = try await aiService.generateResponse(
                model: model,
                systemPrompt: systemPrompt,
                messages: conversationHistory,
                apiKey: apiKey
            )

            for try await token in stream {
                fullResponse += token

                if messageIndex < messages.count {
                    messages[messageIndex] = DebateMessage(
                        speaker: speaker,
                        message: fullResponse,
                        timestamp: Date(),
                        isSystemMessage: false
                    )
                }
            }

            completion(fullResponse)

        } catch {
            let errorMessage = " ❌ Error: \(error.localizedDescription)"
            if messageIndex < messages.count {
                messages[messageIndex] = DebateMessage(
                    speaker: speaker,
                    message: errorMessage,
                    timestamp: Date(),
                    isSystemMessage: false
                )
            }
        }
    }

    private func addMessage(speaker: String?, content: String, isSystem: Bool) {
        let message = DebateMessage(
            speaker: speaker,
            message: content,
            timestamp: Date(),
            isSystemMessage: isSystem
        )
        messages.append(message)
    }

    func speakMessage(_ message: DebateMessage) {
        isConvertingSpeech = true
        Task {
            do {
                try await ttsService.speak(text: message.message, voice: selectedVoice, apiKey: openAIKey)
            } catch {
                print("TTS error: \(error.localizedDescription)")
            }
            await MainActor.run { self.isConvertingSpeech = false }
        }
    }

    func exportDebate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        var export = "# Debate on: \(topic)\n"
        export += "> Generated on: \(formatter.string(from: Date()))\n\n"
        export += "---\n\n"

        for message in messages {
            if let speaker = message.speaker {
                export += "** 🗣️ \(speaker):**\n\n\(message.message)\n\n---\n\n"
            } else {
                export += "*\(message.message)*\n\n---\n\n"
            }
        }

        return export
    }
}
