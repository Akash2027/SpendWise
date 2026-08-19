//
//  ExpenseListView.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var showingAddSheet = false
    @State private var viewMode: ViewMode = .list
    @State private var currentCategoryIndex = 0

    enum ViewMode {
        case list, categories
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Total Card
                        totalCard

                        // Loading indicator
                        if viewModel.isLoadingRates {
                            HStack {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Fetching live rates...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                        }

                        // Segmented Control
                        Picker("View Mode", selection: $viewMode) {
                            Text("📋 List").tag(ViewMode.list)
                            Text("📊 Categories").tag(ViewMode.categories)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)

                        // Content based on mode
                        if viewMode == .list {
                            expenseList
                        } else {
                            categoryPagedView
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("SpendWise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddExpenseView(viewModel: viewModel)
                    .presentationDetents([.medium])
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK") { viewModel.showingError = false }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .onAppear {
                viewModel.configure(with: modelContext)
                viewModel.fetchExchangeRates()
                
                let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                    let storeURL = appSupport.appendingPathComponent("default.store")
                    print("📁 SwiftData store path: \(storeURL.path)")
                
            }
        }
    }

    // MARK: - Total Card
    private var totalCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Total Spent")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if viewModel.isUsingFallback {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }

            let total = viewModel.totalInHomeCurrency
            let pref = SettingsManager.shared.preferredCurrency
            Text("\(total, specifier: "%.2f") \(pref)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(viewModel.isUsingFallback ? .secondary : .primary)
            
            if viewModel.isUsingFallback {
                Text("⚠️ Using raw amounts – rates not loaded")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Expense List
  
    private var expenseList: some View {
        LazyVStack(spacing: 8) {
            if viewModel.expenses.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.expenses, id: \.self) { expense in
                    expenseRow(expense)
                        // ✅ Swipe to delete (iOS 15+)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteExpense(expense)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        // ✅ Long press context menu (backup)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteExpense(expense)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("No expenses yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap the + button to add your first expense")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func expenseRow(_ expense: Expense) -> some View {
        HStack {
            Circle()
                .fill(categoryColor(for: expense.category))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.body)
                    .fontWeight(.semibold)
                Text("\(expense.category) · \(expense.date, format: .dateTime.day().month().year())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(viewModel.convertedAmount(for: expense))
                .font(.callout)
                .fontWeight(.medium)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    // MARK: - Category Paged View (FIXED - Shows all categories with dots)
    private var categoryPagedView: some View {
        let categories = viewModel.categoryTotals
        return Group {
            if categories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    Text("No categories to show")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Add expenses with different categories")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                VStack(spacing: 8) {
                    // Category Name & Count
                    HStack {
                        Text("\(categories.count) categories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Swipe left/right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)

                    // TabView with all categories
                    TabView(selection: $currentCategoryIndex) {
                        ForEach(categories.indices, id: \.self) { index in
                            CategoryCard(
                                category: categories[index].category,
                                total: categories[index].total,
                                isFallback: viewModel.isUsingFallback,
                                homeCurrency: SettingsManager.shared.preferredCurrency
                            )
                            .padding(.horizontal, 16)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))  // Shows dots at bottom
                    .frame(height: 200)
                    .padding(.horizontal, 8)
                    
                    // Category counter
                    Text("\(currentCategoryIndex + 1) of \(categories.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Food": return .orange
        case "Travel": return .blue
        case "Bills": return .red
        case "Shopping": return .purple
        case "Entertainment": return .green
        default: return .gray
        }
    }
}

// MARK: - Category Card View
struct CategoryCard: View {
    let category: String
    let total: Double
    let isFallback: Bool
    let homeCurrency: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: categoryIcon(for: category))
                    .font(.largeTitle)
                    .foregroundStyle(categoryColor(for: category))
            }

            Divider()

            HStack {
                Text("Total spent")
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(total, specifier: "%.2f") \(homeCurrency)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if isFallback {
                        Text("⚠️ Using raw amounts")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Food": return "fork.knife"
        case "Travel": return "airplane"
        case "Bills": return "doc.text"
        case "Shopping": return "bag"
        case "Entertainment": return "tv"
        default: return "questionmark.circle"
        }
    }

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Food": return .orange
        case "Travel": return .blue
        case "Bills": return .red
        case "Shopping": return .purple
        case "Entertainment": return .green
        default: return .gray
        }
    }
}
