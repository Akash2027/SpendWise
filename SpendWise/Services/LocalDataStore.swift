//
//  LocalDataStore.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import Foundation
import SwiftData

class LocalDataStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveExpense(_ expense: Expense) throws {
        modelContext.insert(expense)
        try modelContext.save()
    }

    func fetchAllExpenses() throws -> [Expense] {
        let descriptor = FetchDescriptor<Expense>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }

    func deleteExpense(_ expense: Expense) throws {
        modelContext.delete(expense)
        try modelContext.save()
    }
}
