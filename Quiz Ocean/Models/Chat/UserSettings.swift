//
//  UserSettings.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import Foundation

struct UserSettings: Codable {

    // OpenAI API Key - It is required to use OpenAI API.

    var openAIAPIKey: String = ""

    // Default GPT model - It is used as a default model for chat settings.

    var defaultModel = OpenAIChatModel.gpt35turbo
}
