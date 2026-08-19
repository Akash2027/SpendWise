

# 💰 SpendWise – Expense Tracker

**SpendWise** is a modern iOS expense tracking app built with **SwiftUI** and **SwiftData**. It demonstrates key iOS development concepts including networking, JSON serialization, asynchronous programming, local persistence, and robust error handling – covering 100% of the **Week 4 curriculum** (Networking & Data Persistence).

---

## 📱 Features

- ✅ Add, view, and delete expenses with title, amount, currency, category, and date  
- ✅ Live currency exchange rates via **Frankfurter API**  
- ✅ Automatic conversion to your preferred home currency (USD, EUR, GBP, INR, JPY, etc.)  
- ✅ Category‑based spending breakdown with **swipeable cards**  
- ✅ Dark / Light / System theme toggle (instant apply)  
- ✅ Persist all expenses locally using **SwiftData** (SQLite)  
- ✅ User preferences (currency, theme) stored in **UserDefaults**  
- ✅ Full error handling – network failures, decoding errors, save errors all show user‑friendly alerts  

---

## 🏗️ Architecture

- **Pattern**: MVVM (Model‑View‑ViewModel) + Repository pattern  
- **UI**: SwiftUI  
- **Persistence**: SwiftData (iOS 17+)  
- **Networking**: URLSession with `async/await`  
- **Serialization**: Codable (JSON encoding/decoding)  
- **State Management**: ObservableObject, `@Published`, `@EnvironmentObject`

```
Views (SwiftUI)
       ↓
ViewModel (ObservableObject)
       ↓
Repository / Services
       ↓
APIService (networking) & LocalDataStore (SwiftData)
       ↓
Frankfurter API & SQLite (`default.store`)
```

---

## 📁 Project Structure

```
SpendWise/
├── App/
│   └── SpendWiseApp.swift                # App entry, modelContainer, ThemeManager injection
├── Managers/
│   └── ThemeManager.swift                # Handles theme state (ObservableObject)
├── Models/
│   ├── Expense.swift                     # SwiftData @Model class
│   ├── ExchangeRate.swift                # Codable struct for API response
│   └── AppTheme.swift                    # Theme enum with colorScheme mapping
├── Services/
│   ├── APIService.swift                  # URLSession + async/await + Codable
│   ├── LocalDataStore.swift              # SwiftData CRUD operations
│   └── SettingsManager.swift             # UserDefaults wrapper
├── ViewModels/
│   └── ExpenseViewModel.swift            # ObservableObject, orchestrates data
├── Views/
│   ├── ExpenseListView.swift             # Main list + category toggle
│   ├── AddExpenseView.swift              # Form sheet
│   └── SettingsView.swift                # Theme, currency, rates, delete all
└── Utilities/
    └── ExpenseError.swift                # Custom error enum
```

---

## 🧪 Week 4 Topics Demonstrated

| Topic | Implementation |
| :--- | :--- |
| **HTTP & Network Requests** | `APIService` uses `URLSession.shared.data(from:)` with GET requests to fetch live exchange rates. |
| **Data Serialization** | `ExchangeRate` conforms to `Codable`; `JSONDecoder` parses the API response. |
| **Async/Await** | All network calls are `async` functions called with `await` inside `Task` blocks – UI stays responsive. |
| **Local Storage** | `Expense` is a SwiftData `@Model`; `LocalDataStore` provides save, fetch, and delete operations. |
| **UserDefaults** | `SettingsManager` stores the user's preferred currency and theme preference. |
| **Error Handling** | Custom `ExpenseError` enum with `LocalizedError`; all `do-catch` blocks display user‑friendly alerts. |

---

## 📦 Requirements

- **iOS 17.0** or later  
- **Xcode 15.0** or later  
- Swift 5.9  

---

## 🚀 Getting Started

1. **Clone the repository** (or unzip the project folder).
2. Open `SpendWise.xcodeproj` in Xcode.
3. Select a target simulator (iPhone 15 / iOS 17+).
4. Press `⌘R` to build and run.

> No third‑party dependencies – everything uses native Apple frameworks.

---

## 🔧 Configuration

### API
The app uses the free [Frankfurter API](https://www.frankfurter.app) for exchange rates.  
The base currency is fixed to **USD**, and rates are fetched for all supported currencies.

### Currency & Theme
- **Home Currency**: Change in Settings → the app will convert all expenses automatically.
- **Theme**: Choose Light, Dark, or System in Settings – changes apply instantly.

---

## 🧹 Data Persistence

- All expenses are stored locally in a SQLite database managed by SwiftData.
- The database file is located at:  
  `~/Library/Developer/CoreSimulator/Devices/.../data/Containers/Data/Application/.../Library/Application Support/default.store`

- You can inspect the data using [DB Browser for SQLite](https://sqlitebrowser.org) or the `sqlite3` command line.

---

## 🛠️ Testing Error Handling

- **Network errors**: Use Simulator's **Network Link Conditioner** (Hardware → Toggle Network Link Conditioner) to simulate offline / slow networks.
- **API failures**: App shows a clear alert with the error description.
- **Save errors**: If SwiftData fails, the user sees a meaningful message – no crash.

---

## 🖼️ Screenshots

<div align="center"> <img src="https://github.com/user-attachments/assets/5029506b-008d-4757-8b08-dc5e675ff1ac" width="250" alt="Home Screen" /> <img src="https://github.com/user-attachments/assets/fce723db-f7f0-4564-a785-bf14ec212731" width="250" alt="Add Expense" /> <img src="https://github.com/user-attachments/assets/19884aaf-e31a-4924-aba7-ffe406c0ee98" width="250" alt="Settings" /> </div><p align="center"> <em>Left to right: Home Dashboard · Add Expense · Settings</em> </p>

---

## 📄 License

This project was created for educational purposes as part of a curriculum assignment.  
Feel free to use it as a reference for learning iOS development.

---

## 👨‍💻 Author

**Akash K.**  
Week 4 Assignment – Networking & Data Persistence  
August 2026

---

## 🙌 Acknowledgments

- [Frankfurter API](https://www.frankfurter.app) for free exchange rate data.
- Apple’s SwiftUI, SwiftData, and URLSession frameworks.

---

**Enjoy tracking your expenses – in any currency!** 💸
