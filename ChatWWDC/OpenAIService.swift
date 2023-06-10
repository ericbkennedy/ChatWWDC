//
//  OpenAIService.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import Foundation

class OpenAIService {
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-3.5-turbo"
    
    /// Send messages and handle streaming responses with streamCompletion
    func send(messages: [Message], streamCompletion: @escaping (String) -> Void) async {
        guard let endpointURL = URL(string: endpoint) else { return }
        
        // only send supported message fields (role, content, name) to OpenAI
        let trimmedMessages = messages.map({ ChatGPTMessage(role: $0.role, content: $0.content) })
        
        let requestBody = ChatGPTRequest(model: model, messages: trimmedMessages)
        
        do {
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(Constants.openAIAPIKey)"
            ]
            
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (stream, _) = try await URLSession.shared.bytes(for: request)
            
            for try await line in stream.lines {
                guard let message = parse(line) else { continue }
                
                print(message, terminator: "")
                streamCompletion(message)
            }
        } catch {
            print("Error occurred \(error)")
        }
    }
    
    /// Parse a line from the stream and extract the message
    func parse(_ line: String) -> String? {
        let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        guard components.count == 2, components[0] == "data" else { return nil }

        let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

        if message == "[DONE]" { // ChatGPT stream terminator
            return ""
        } else {
            let chunk = try? JSONDecoder().decode(ChatGPTResponse.self, from: message.data(using: .utf8)!)
           return chunk?.choices.first?.delta.content
        }
    }
}

enum SenderRole: String, Codable {
    case user
    case assistant
    case system
}

struct ChatGPTMessage: Codable  {
    let role: SenderRole
    let content: String
}

struct ChatGPTRequest: Encodable {
    let model: String
    let messages: [ChatGPTMessage]
    let stream = true
}

struct ChatGPTResponse: Decodable {
    let choices: [ChatGPTChoice]
}

struct ChatGPTChoice: Decodable {
    struct Delta: Decodable {
      let role: String?
      let content: String?
    }
    let delta: Delta
}
