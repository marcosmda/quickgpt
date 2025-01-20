//
//  File.swift
//  
//
//  Created by Marcos Vinicius Majeveski De Angeli on 20/01/25.
//

import Foundation

struct OpenAIService {

    enum OpenAIError: Error {
        case noAPIKey
        case noContent
        case invalidURL
        case invalidBody
    }

    static func getAIMessage(
        content: String,
        apiKey: String,
        model: String,
        temperature: Double,
        maxCompletionTokens: Int,
        topP: Double,
        frequencyPenalty: Double,
        presencePenalty: Double,
        stream: Bool
    ) async throws {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw OpenAIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let chatCompletionRequest = OpenAIRequestBody(
            model: model,
            messages: [OpenAIMessage(role: .user, content: content)],
            temperature: temperature,
            maxCompletionTokens: maxCompletionTokens,
            topP: topP,
            frequencyPenalty: frequencyPenalty,
            presencePenalty: presencePenalty,
            stream: stream
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let body = try? encoder.encode(chatCompletionRequest) else {
            print("Could not construct the API request.")
            throw OpenAIError.invalidBody
        }

        request.httpBody = body

        if stream {
            do {
                let (response, _) = try await URLSession.shared.bytes(for: request)

                for try await line in response.lines {
                    guard !line.isEmpty else{ return }
                    
                    let content = String(line[line.index(line.startIndex, offsetBy: 6)..<line.endIndex])
                    guard let data = content.data(using: .utf8),
                          let result = try? JSONDecoder().decode(StreamChatResponse.self, from: data)
                    else {
                        print("no response from the API")
                        throw OpenAIError.noContent
                    }

                    let choices = result.choices
                    guard let messageContent = choices.first?.delta?.content else { return }

                    print(messageContent, terminator: "")
                }
            }
        } else {
            var data: Data?
            (data, _) = try await URLSession.shared.data(for: request)

            guard let data = data,
                    let response = try? JSONDecoder().decode(ChatResponse.self, from: data)
            else {
                print("no response from the API")
                throw OpenAIError.noContent
            }

            let choices = response.choices
            guard let messageContent = choices.first?.message.content else { throw OpenAIError.noContent }
            print("\n\(messageContent)\n")
            return
        }
    }
}
