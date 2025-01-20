// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation
import Security

@main
struct Quickgpt: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift CLI application with multiple commands.",
        subcommands: [Chat.self, SetModel.self, SetApiKey.self, DeleteApiKey.self],
        defaultSubcommand: Chat.self,
        helpNames: [.long, .short]
    )

    static let defaultModelKey = "quickgpt-defaults-defaultModel"
    static let defaultApiKey = "quickgpt-defaults-defaultApiKey"

    struct Chat: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Makes a request with the given input for the given model. If no model is provided, the default will be used.")
        @Argument(help: "Your input for the AI model. A question, a request, a greeting or anything else in a text format.")
        var input: String

        @Option(name: .shortAndLong, help: "OpenAI API key to be used. If the default API key was set this argument is not needed.")
        var key: String?

        @Option(name: .shortAndLong, help: "OpenAI available model to be used, or none to use default model.")
        var model: String?

        @Option(name: .shortAndLong, help: "Temperature of the model. Lower values will result in less hallucinations, but normally more repetitive and deterministic outputs. This value has to be between 0 and 1.")
        var temperature: Double = 1

        @Option(name: .long, help: "The max number of tokens to generate. This value has to be between 1 and 16383.")
        var maxCompletionTokens: Int = 2048

        @Option(name: .long, help: "Defines the probabilistic sum of tokens that should be considered for each subsequent token. This value has to be between 0 and 1.")
        var topP: Double = 1

        @Option(name: .shortAndLong, help: "How much to penalize new tokens based on their existing frequency in the text so far. Decreases the model's likelihood to repeat the same line verbatim. This value has to be between 0 and 2.")
        var frequencyPenalty: Double = 0

        @Option(name: .shortAndLong, help: "How much to penalize new tokens based on whether they appear in the text so far. Increases the model's likelihood to talk about new topics. This value has to be between 0 and 2.")
        var presencePenalty: Double = 0

        @Option(name: .shortAndLong, help: "Wheter to stream or not the response.")
        var stream: Bool = true

        public func run() async {
            guard !input.isEmpty else {
                print("No input provided")
                return
            }
            guard let keyToUse = key ?? KeychainService.retrieveKeyValue(at: Quickgpt.defaultApiKey) else {
                print("could not infer the API key. If no key was set as default, please provide the desired key to be used as an argument using the -k option or set the default key with the `set-key` command")
                return
            }
            guard let modelToUse = model ?? UserDefaults.standard.string(forKey: Quickgpt.defaultModelKey) else {
                print("Could not infer the model to be used. Try setting the model you want to use as default.")
                return
            }
            guard temperature >= 0 && temperature <= 1 else {
                print("temperature value should be between and including 0 and 1")
                return
            }
            guard maxCompletionTokens >= 1 && maxCompletionTokens <= 16383 else {
                print("maxCompletionTokens value should be between and including 0 and 16383")
                return
            }
            guard topP >= 0 && topP <= 1 else {
                print("topP value should be between and including 0 and 1")
                return
            }
            guard frequencyPenalty >= 0 && frequencyPenalty <= 2 else {
                print("frequencyPenalty value should be between and including 0 and 2")
                return
            }
            guard presencePenalty >= 0 && presencePenalty <= 2 else {
                print("presencePenalty value should be between and including 0 and 2")
                return
            }

            do {
                try await OpenAIService.getAIMessage(
                    content: input,
                    apiKey: keyToUse,
                    model: modelToUse,
                    temperature: temperature,
                    maxCompletionTokens: maxCompletionTokens,
                    topP: topP,
                    frequencyPenalty: frequencyPenalty,
                    presencePenalty: presencePenalty,
                    stream: stream
                )
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    struct SetModel: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Sets a defautl model for easier requests.")

        @Argument(help: "openAI available model to be set as default.")
        var model: String = "gpt-4o"

        public func run() {
            UserDefaults.standard.set(model, forKey: Quickgpt.defaultModelKey)
            if let value = UserDefaults.standard.string(forKey: Quickgpt.defaultModelKey) {
                print("The model \(value) is now default for requests.")
            } else {
                print("For some obscure reason the operation could not be complete.")
            }
        }
    }

    struct SetApiKey: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Sets the defautl API key for easier requests.")

        @Argument(help: "OpenAI API key to be set as default. It's stored on the keychain.")
        var key: String

        public func run() {
            guard KeychainService.storeKeyValue(keychainKey: Quickgpt.defaultApiKey, apiKey: key) else {
                print("Something went wrong when storing your key to the keychain. Try making a chat request with your API key using the option -k, --key.")
                return
            }
            if let value = KeychainService.retrieveKeyValue(at: Quickgpt.defaultApiKey) {
                print("The API key \(value) is now default for requests.")
            } else {
                print("For some obscure reason the operation could not be complete.")
            }
        }
    }

    struct DeleteApiKey: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Deletes the defautl API key stored on the keychain.")

        public func run() {
            guard KeychainService.deleteKeyValue(for: Quickgpt.defaultApiKey) else {
                print("Something went wrong when removing your key from the keychain. You can remove it manually via the \"\(Quickgpt.defaultApiKey)\" identifier.")
                return
            }
            print("Your API key was removed with success.")
        }
    }
}
