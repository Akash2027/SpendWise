//
//  ExpenseError.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import Foundation

enum ExpenseError: LocalizedError {
    case networkFailed(underlying: Error)
    case decodingFailed
    case saveFailed(underlying: Error)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .networkFailed(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingFailed:
            return "Failed to decode data from server."
        case .saveFailed(let error):
            return "Could not save data: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data received."
        }
    }
}
