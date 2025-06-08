//
//  AIModel.swift
//  AIDebate
//
//  Created by Jiping Yang on 6/7/25.
//

import Foundation

struct AIModel {
    let name: String
    let modelId: String
    let type: ModelType
    let baseURL: String?
    
    enum ModelType {
        case openai, claude, gemini, deepseek, groq
    }
}
