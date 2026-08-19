//
//  ThemeManager.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme {
        didSet {
            SettingsManager.shared.appTheme = currentTheme.rawValue
        }
    }
    
    private init() {
        let saved = SettingsManager.shared.appTheme
        self.currentTheme = AppTheme(rawValue: saved) ?? .system
    }
}
