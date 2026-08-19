//
//  ExchangeRate.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//



// Matches the free API: https://api.frankfurter.app/latest?from=USD
import Foundation

struct ExchangeRate: Codable {
    let base: String
    let date: String
    var rates: [String: Double]   // Changed to var

    // ✅ Computed property that always includes base currency
    var allRates: [String: Double] {
        var copy = rates
        copy[base] = 1.0
        return copy
    }
}
