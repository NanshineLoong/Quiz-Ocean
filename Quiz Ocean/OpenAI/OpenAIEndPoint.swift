//
//  OpenAIEndPoint.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import Foundation

// OpenAI API endpoint
// web: https://platform.openai.com/docs/api-reference/chat/create
// It is still beta. This might be changed.

enum OpenAIEndpoint {
    static let path = "/v1/chat/completions"
    static let method = "POST"
    static let baseURL = "https://api.openai.com"
}
