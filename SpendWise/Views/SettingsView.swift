//
//  SettingsView.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedCurrency = SettingsManager.shared.preferredCurrency
    @State private var selectedTheme = SettingsManager.shared.appTheme
    @State private var showingDeleteConfirmation = false
    @State private var showingDeleteResult = false

    let currencies = ["USD", "EUR", "GBP", "INR", "JPY"]

    var body: some View {
        List {
            // MARK: - Theme Section
            Section {
                Picker("Appearance", selection: $selectedTheme) {
                    ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                        HStack {
                            switch theme {
                            case .light:
                                Image(systemName: "sun.max.fill")
                                Text("Light")
                            case .dark:
                                Image(systemName: "moon.fill")
                                Text("Dark")
                            case .system:
                                Image(systemName: "iphone")
                                Text("System Default")
                            }
                        }
                        .tag(theme.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedTheme) { _, newValue in
                    SettingsManager.shared.appTheme = newValue
                    // Update theme manager to reflect changes immediately
                    if let theme = AppTheme(rawValue: newValue) {
                        themeManager.currentTheme = theme
                    }
                }
            } header: {
                Text("Theme")
            } footer: {
                Text("Choose between Light, Dark, or match your device settings.")
            }

            // MARK: - Currency Section
            Section {
                Picker("Home Currency", selection: $selectedCurrency) {
                    ForEach(currencies, id: \.self) { curr in
                        Text(curr)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedCurrency) { _, newValue in
                    SettingsManager.shared.preferredCurrency = newValue
                    // Refresh the view to update totals
                    viewModel.loadExpenses()
                }
            } header: {
                Text("Currency")
            }

            // MARK: - Exchange Rates Section
            Section {
                HStack {
                    Text("1 USD = ")
                    Spacer()
                    if viewModel.isLoadingRates {
                        ProgressView()
                            .controlSize(.small)
                    } else if let rates = viewModel.exchangeRate?.rates,
                              let rate = rates[selectedCurrency] {
                   
                        Text("\(rate, specifier: "%.2f") \(selectedCurrency)")
                            .fontWeight(.medium)
                    } else {
                        Text("No rate available")
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    viewModel.fetchExchangeRates()
                } label: {
                    Label("Refresh Now", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                if let lastUpdate = viewModel.exchangeRate?.date {
                    Text("Updated: \(lastUpdate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Live Rates")
            } footer: {
                Text("Rates fetched from frankfurter.app API")
            }

            // MARK: - Data Section
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete All Data", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("This will permanently delete all your expenses.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("Are you sure you want to delete ALL your expenses? This action cannot be undone.")
        }
        .alert("Data Deleted", isPresented: $showingDeleteResult) {
            Button("OK") { }
        } message: {
            Text("All expenses have been permanently deleted.")
        }
        .onAppear {
            // Sync the theme picker with current theme
            selectedTheme = SettingsManager.shared.appTheme
        }
    }
    
    // MARK: - Delete All Data
    private func deleteAllData() {
        // Get all expenses from ViewModel
        let expensesToDelete = viewModel.expenses
        
        // Delete each expense
        for expense in expensesToDelete {
            modelContext.delete(expense)
        }
        
        // Save changes
        do {
            try modelContext.save()
            viewModel.loadExpenses() // Refresh the list
            showingDeleteResult = true
        } catch {
            viewModel.errorMessage = "Failed to delete data: \(error.localizedDescription)"
            viewModel.showingError = true
        }
    }
}
