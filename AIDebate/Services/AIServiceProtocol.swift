import Foundation

protocol AIServiceProtocol {
    func generateResponse(
        model: AIModel,
        systemPrompt: String,
        messages: [ChatMessage],
        apiKey: String
    ) async throws -> AsyncThrowingStream<String, Error>
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

class AIService: AIServiceProtocol {
    func generateResponse(
        model: AIModel,
        systemPrompt: String,
        messages: [ChatMessage],
        apiKey: String
    ) async throws -> AsyncThrowingStream<String, Error> {
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    switch model.type {
                    case .openai, .deepseek, .groq:
                        try await streamOpenAIResponse(
                            model: model,
                            systemPrompt: systemPrompt,
                            messages: messages,
                            apiKey: apiKey,
                            continuation: continuation
                        )
                    case .claude:
                        try await streamClaudeResponse(
                            model: model,
                            systemPrompt: systemPrompt,
                            messages: messages,
                            apiKey: apiKey,
                            continuation: continuation
                        )
                    case .gemini:
                        try await streamGeminiResponse(
                            model: model,
                            systemPrompt: systemPrompt,
                            messages: messages,
                            apiKey: apiKey,
                            continuation: continuation
                        )
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func streamOpenAIResponse(
        model: AIModel,
        systemPrompt: String,
        messages: [ChatMessage],
        apiKey: String,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let url = URL(string: "\(model.baseURL ?? "https://api.openai.com")/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var allMessages = [ChatMessage(role: "system", content: systemPrompt)]
        allMessages.append(contentsOf: messages)
        
        let body = [
            "model": model.modelId,
            "messages": allMessages.map { ["role": $0.role, "content": $0.content] },
            "stream": true,
            "max_tokens": 1500
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        for try await line in data.lines {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))
                if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                    break
                }
                
                if let data = jsonString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let delta = firstChoice["delta"] as? [String: Any],
                   let content = delta["content"] as? String {
                    continuation.yield(content)
                }
            }
        }
        
        continuation.finish()
    }
    
    private func streamClaudeResponse(
        model: AIModel,
        systemPrompt: String,
        messages: [ChatMessage],
        apiKey: String,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let body = [
            "model": model.modelId,
            "system": systemPrompt,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "stream": true,
            "max_tokens": 1500
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        for try await line in data.lines {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))
                if let data = jsonString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let type = json["type"] as? String,
                   type == "content_block_delta",
                   let delta = json["delta"] as? [String: Any],
                   let text = delta["text"] as? String {
                    continuation.yield(text)
                }
            }
        }
        
        continuation.finish()
    }
    
    private func streamGeminiResponse(
        model: AIModel,
        systemPrompt: String,
        messages: [ChatMessage],
        apiKey: String,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model.modelId):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var contents: [[String: Any]] = []
        
        // Add system prompt as first user message
        let fullPrompt = systemPrompt + "\n\n" + (messages.last?.content ?? "Please provide your opening statement.")
        contents.append([
            "parts": [["text": fullPrompt]],
            "role": "user"
        ])
        
        let body = [
            "contents": contents,
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 1500
            ]
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let candidates = json["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let firstPart = parts.first,
           let text = firstPart["text"] as? String {
            
            // Simulate streaming by yielding words gradually
            let words = text.components(separatedBy: " ")
            for word in words {
                continuation.yield(word + " ")
                try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            }
        }
        
        continuation.finish()
    }
}
