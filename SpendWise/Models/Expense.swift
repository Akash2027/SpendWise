//
//  Expense.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var title: String
    var amount: Double
    var currency: String
    var category: String
    var date: Date

    init(title: String, amount: Double, currency: String, category: String, date: Date) {
        self.title = title
        self.amount = amount
        self.currency = currency
        self.category = category
        self.date = date
    }
}
