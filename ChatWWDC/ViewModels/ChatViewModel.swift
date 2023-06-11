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
    
    func reset() {
        messages = []
    }
    
    /// Default behavor sends currentInput property value bound to text input to ChatGPT.
    /// If url and non-empty urlTranscript are provided, send chatGPT the urlTranscript and show only the url in chat transcript
    func sendMessage(url: String = "", urlTranscript: String = "") {
        
        var messageText = currentInput
        
        if urlTranscript.isEmpty == false {
            messageText = "Summarize the key points of this Apple Developer talk: \(urlTranscript)"
        }
        
        let userMessage = Message(id: UUID(),
                                  role: .user,
                                  url: url,
                                  content: messageText,
                                  created: Date())
        messages.append(userMessage)
        currentInput = ""
        
        let agentMessage = Message(id: UUID(), role: .assistant, url: "", content: ". . .", created: Date())
        messages.append(agentMessage)
        let pendingMessageIndex = messages.count - 1
    
        Task {
            await openAIService.send(messages: [userMessage],
                                     streamCompletion: { newText in
                DispatchQueue.main.async {
                    self.updatePendingMessageWithString(newText, pendingMessageIndex: pendingMessageIndex)
                }
            })
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
    let url: String // used so the client can show the url and not the full transcript (in content)
    var content: String
    let created: Date
}
