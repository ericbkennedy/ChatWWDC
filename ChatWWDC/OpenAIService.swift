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
    
    func sendMessages(messages: [Message]) async -> ChatGPTResponse? {
        guard let endpointURL = URL(string: endpoint) else { return nil }
        
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
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            
            let chatResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: responseData)
            
            return chatResponse
        } catch {
            print("Error occurred \(error)")
        }
        
        return nil
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
    let stream = false
}

struct ChatGPTResponse: Decodable {
    let choices: [ChatGPTChoice]
}

struct ChatGPTChoice: Decodable {
    let message: ChatGPTMessage
}

