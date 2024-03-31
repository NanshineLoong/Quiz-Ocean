//
//  ChatSettings.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import Foundation

struct ChatSettings: Codable {
    // Model
    var chatModel: OpenAIChatModel
    
    //Parameters
    var temperature: Double = OpenAIChatConversation.temperatureDefault
    var topProbabilityMass: Double = OpenAIChatConversation.topProbabilityMassDefault
    var maxTokens: Double = Double(AppConstant.maxTokenDefault)
    var presencePenalty: Double = OpenAIChatConversation.presencePenaltyDefault
    var frequencyPenalty: Double = OpenAIChatConversation.frequencyPenaltyDefault

    // System role

    var systemContent: String = AppConstant.systemRoleContentDefault

}
