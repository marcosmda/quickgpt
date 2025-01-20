//
//  File.swift
//  
//
//  Created by Marcos Vinicius Majeveski De Angeli on 20/01/25.
//

import Foundation

struct OpenAIMessage: Encodable {
    enum Role: String, Encodable {
        case developer
        case user
        case assistant
    }

    let role: String
    let content: String

    public init(role: Role = Role.user,
                content: String) {
        self.role = role.rawValue
        self.content = content
    }
}

struct OpenAIRequestBody: Encodable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxCompletionTokens: Int
    let topP: Double // 0 - 1
    let frequencyPenalty: Double // 0 - 2
    let presencePenalty: Double // 0 - 2
    let stream: Bool
    let responseFormat: [String: String] = ["type": "text"]

    init(model: String,
         messages: [OpenAIMessage],
         temperature: Double,
         maxCompletionTokens: Int,
         topP: Double,
         frequencyPenalty: Double,
         presencePenalty: Double,
         stream: Bool) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxCompletionTokens = maxCompletionTokens
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.stream = stream
    }
}

struct ChatResponse: Codable {
    let choices: [Choice]
    let model: String
}

struct Choice: Codable {
    let index: Int
    let message: Message
}

struct Message: Codable {
    let role: String
    let content: String
}

struct StreamChatResponse: Codable {
    let choices: [StreamChoice]
}

struct StreamChoice: Codable {
    let delta: StreamDelta?
}

struct StreamDelta: Codable {
    let content: String?
}
