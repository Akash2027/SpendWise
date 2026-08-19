//
//  SpendWiseApp.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import SwiftUI
import SwiftData

@main
struct SpendWiseApp: App {
    @StateObject private var themeManager = ThemeManager.shared  // ← Creates the theme manager
    
    var body: some Scene {
        WindowGroup {
            ExpenseListView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)  // ← Applies theme
                .modelContainer(for: Expense.self)
                .environmentObject(themeManager)  // ← THIS is where you add it!
        }
    }
}
