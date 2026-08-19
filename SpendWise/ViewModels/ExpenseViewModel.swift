//
//  ExpenseViewModel.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var exchangeRate: ExchangeRate?
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var isLoadingRates = false

    private let apiService = APIService()
    private var dataStore: LocalDataStore?

    // MARK: - Total in Home Currency (with conversion)
    var totalInHomeCurrency: Double {
        let home = SettingsManager.shared.preferredCurrency
        
        // If no rates, show raw sum
        guard let rates = exchangeRate?.rates, !rates.isEmpty else {
            return expenses.reduce(0) { $0 + $1.amount }
        }
        
        return expenses.reduce(0) { sum, expense in
            if expense.currency == home {
                return sum + expense.amount
            }
            
            guard let rateHome = rates[home],
                  let rateExpense = rates[expense.currency],
                  rateExpense > 0 else {
                return sum + expense.amount
            }
            
            let converted = expense.amount * (rateHome / rateExpense)
            return sum + converted
        }
    }
    
   
    var isUsingFallback: Bool {
        guard let rates = exchangeRate?.rates else { return true }
        return rates.isEmpty
    }


    // MARK: - Category Totals (THIS IS THE FIX)
    var categoryTotals: [(category: String, total: Double)] {
        let home = SettingsManager.shared.preferredCurrency
        guard let rates = exchangeRate?.rates, !rates.isEmpty else {
            // Fallback: raw amounts without conversion
            var dict: [String: Double] = [:]
            for expense in expenses {
                dict[expense.category, default: 0] += expense.amount
            }
            return dict.map { (category: $0.key, total: $0.value) }
                .sorted { $0.total > $1.total }
        }

        var dict: [String: Double] = [:]
        for expense in expenses {
            let converted: Double
            if expense.currency == home {
                converted = expense.amount
            } else {
                guard let rateHome = rates[home],
                      let rateExpense = rates[expense.currency],
                      rateExpense > 0 else {
                    converted = expense.amount
                    continue
                }
                converted = expense.amount * (rateHome / rateExpense)
            }
            dict[expense.category, default: 0] += converted
        }
        return dict.map { (category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }

    // MARK: - Persistence
    func configure(with modelContext: ModelContext) {
        self.dataStore = LocalDataStore(modelContext: modelContext)
        loadExpenses()
    }

    func loadExpenses() {
        guard let dataStore = dataStore else { return }
        do {
            self.expenses = try dataStore.fetchAllExpenses()
        } catch {
            handleError(ExpenseError.saveFailed(underlying: error))
        }
    }

    func addExpense(title: String, amount: Double, currency: String, category: String, date: Date) {
        guard let dataStore = dataStore else { return }
        let newExpense = Expense(title: title, amount: amount, currency: currency, category: category, date: date)

        do {
            try dataStore.saveExpense(newExpense)
            loadExpenses()
        } catch {
            handleError(ExpenseError.saveFailed(underlying: error))
        }
    }

    func deleteExpense(_ expense: Expense) {
        guard let dataStore = dataStore else { return }
        do {
            try dataStore.deleteExpense(expense)
            loadExpenses()
        } catch {
            handleError(ExpenseError.saveFailed(underlying: error))
        }
    }

    // MARK: - Networking
    func fetchExchangeRates() {
        isLoadingRates = true
        Task {
            do {
                let rates = try await apiService.fetchExchangeRates(base: "USD")
                self.exchangeRate = rates
                self.isLoadingRates = false
                print("✅ Rates fetched: \(rates.rates)")
            } catch {
                print("❌ Fetch error: \(error)") 
                handleError(error)
                self.isLoadingRates = false
            }
        }
    }

    // MARK: - Conversion Helper
    func convertedAmount(for expense: Expense) -> String {
        let preferred = SettingsManager.shared.preferredCurrency
        guard let rates = exchangeRate?.rates,
              !rates.isEmpty,
              let rateHome = rates[preferred],
              let rateExpense = rates[expense.currency],
              rateExpense > 0,
              preferred != expense.currency else {
            return String(format: "%.2f %@", expense.amount, expense.currency)
        }

        let converted = expense.amount * (rateHome / rateExpense)
        return String(format: "%.2f %@ (≈ %.2f %@)", expense.amount, expense.currency, converted, preferred)
        
        ///Converted Amount = Original Amount × (Home Currency Rate ÷ Expense Currency Rate)
        /// 
    }

    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        if let expenseError = error as? ExpenseError {
            errorMessage = expenseError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showingError = true
    }
}
