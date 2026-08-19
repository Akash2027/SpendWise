//
//  SettingsManager.swift
//  SpendWise
//
//  Created by Akash K on 17/08/26.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let preferredCurrency = "preferredCurrency"
        static let appTheme = "appTheme"
    }

    // Currency
    var preferredCurrency: String {
        get { defaults.string(forKey: Keys.preferredCurrency) ?? "USD" }
        set { defaults.set(newValue, forKey: Keys.preferredCurrency) }
    }

    // Theme
    var appTheme: String {
        get { defaults.string(forKey: Keys.appTheme) ?? "system" }
        set { defaults.set(newValue, forKey: Keys.appTheme) }
    }
}
