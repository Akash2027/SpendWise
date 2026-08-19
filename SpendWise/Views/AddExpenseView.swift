//
//  AddExpenseView.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExpenseViewModel

    @State private var title = ""
    @State private var amount = ""
    @State private var currency = "USD"
    @State private var category = "Food"
    @State private var date = Date()

    let currencies = ["USD", "EUR", "GBP", "INR", "JPY"]
    let categories = ["Food", "Travel", "Bills", "Shopping", "Entertainment"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { curr in
                            Text(curr)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section {
                    Button(action: saveExpense) {
                        Text("Save Expense")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fontWeight(.semibold)
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveExpense() {
        guard let amountVal = Double(amount) else { return }
        viewModel.addExpense(title: title, amount: amountVal, currency: currency, category: category, date: date)
        dismiss()
    }
}
