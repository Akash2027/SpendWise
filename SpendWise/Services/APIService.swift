//
//  APIService.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

/*
// ❌ MOCK DATA - COMMENT OUT THIS BLOCK
return ExchangeRate(
    base: "USD",
    date: "2026-08-17",
    rates: [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.78,
        "INR": 83.50,
        "JPY": 147.50
    ]
)
*/
import Foundation

class APIService {
    private let baseURL = "https://api.frankfurter.app"
    private let session = URLSession.shared

    func fetchExchangeRates(base: String = "USD") async throws -> ExchangeRate {
        guard let url = URL(string: "\(baseURL)/latest?from=\(base)") else {
            throw ExpenseError.invalidData
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ExpenseError.networkFailed(underlying: URLError(.badServerResponse))
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            var decoded = try decoder.decode(ExchangeRate.self, from: data)
            
            // ✅ ADD BASE CURRENCY WITH RATE 1.0
            var rates = decoded.rates
            rates[decoded.base] = 1.0
            decoded = ExchangeRate(base: decoded.base, date: decoded.date, rates: rates)
            
            return decoded
        } catch _ as DecodingError {
            throw ExpenseError.decodingFailed
        } catch {
            throw ExpenseError.networkFailed(underlying: error)
        }
    }
}
