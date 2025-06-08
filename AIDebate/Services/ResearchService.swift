import Foundation

class ResearchService {
    func conductResearch(topic: String, apiKey: String) async throws -> ResearchBriefing {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Please perform a Google search to find the strongest arguments both FOR and AGAINST the topic: '\(topic)'.
        
        Based on your search results, generate two concise, point-form summaries.
        
        The output MUST have two sections. Start the first section with the exact heading '## Affirmative Arguments' and the second with '## Opposition Arguments'.
        Response in Chinese
        """
        
        let body = [
            "contents": [
                [
                    "parts": [["text": prompt]],
                    "role": "user"
                ]
            ],
            "tools": [
                [
                    "googleSearch": [:]
                ]
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
            
            if text.contains("## Opposition Arguments") && text.contains("## Affirmative Arguments") {
                let components = text.components(separatedBy: "## Opposition Arguments")
                let affirmative = components[0].replacingOccurrences(of: "## Affirmative Arguments", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                let opposition = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                return ResearchBriefing(affirmativeArguments: affirmative, oppositionArguments: opposition)
            } else {
                return ResearchBriefing(affirmativeArguments: text, oppositionArguments: text)
            }
        }
        
        throw URLError(.cannotParseResponse)
    }
}
