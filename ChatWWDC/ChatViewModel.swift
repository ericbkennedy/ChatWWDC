//
//  ChatViewModel.swift
//  ChatWWDC
//
//  Created by Eric Kennedy on 6/10/23.
//

import Foundation

class ChatViewModel : ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    @Published var totalResponseCount: Int = 0
    
    private let openAIService = OpenAIService()
    
    func sendMessage() {
        let userMessage = Message(id: UUID(),
                                  role: .user,
                                  content: currentInput,
                                  created: Date())
        messages.append(userMessage)
        currentInput = ""
        
        let agentMessage = Message(id: UUID(), role: .assistant, content: ". . .", created: Date())
        messages.append(agentMessage)
        let pendingMessageIndex = messages.count - 1
    
        Task {
            let response = await openAIService.sendMessages(messages: [userMessage])
            
            DispatchQueue.main.async {
                var responseMessage = "No response received"
                if let receivedOpenAIMessage = response?.choices.first?.message {
                    responseMessage = receivedOpenAIMessage.content
                }
                self.updatePendingMessageWithString(responseMessage, pendingMessageIndex: pendingMessageIndex)
            }
        }
    }
    
    func updatePendingMessageWithString(_ newText: String, pendingMessageIndex: Int) {
        if (self.messages[pendingMessageIndex].content == ". . .") {
            self.messages[pendingMessageIndex].content = ""
        }
        self.messages[pendingMessageIndex].content += newText
        self.totalResponseCount += 1
    }
}

struct Message: Decodable {
    let id: UUID
    let role: SenderRole
    var content: String
    let created: Date
}
