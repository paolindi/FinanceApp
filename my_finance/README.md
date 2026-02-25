# 📊 My Finance (Personal Finance App)

A comprehensive and intuitive mobile application developed with Flutter to manage personal finances. The app allows tracking of bank accounts, expenses, income, investment portfolios, and loans, providing a clear overview of your real **Net Worth** through natively generated charts and advanced statistics.

## ✨ Key Features

### 🏠 Dashboard & Net Worth

* **Real Wealth Calculation:** Automatic real-time calculation of Net Worth (Liquidity + Investments - Remaining Debits).
* **Account Management:** Add, edit, and remove bank accounts or cards, with always-updated balances and liquidity distribution charts.

### 💸 Transaction Tracking

* **Income & Expenses:** Quickly record daily transactions.
* **Dynamic Categories:** Intelligent dropdown menus that show different categories depending on whether you are entering Income (e.g., Salary, Gift) or an Expense (e.g., Food, Home, Bills).
* **Safety Checks:** Rigorous input validation to prevent incorrect amounts, empty fields, or application crashes.

### 📈 Investment Portfolio

* **Multi-Asset Tracking:** Manage Stocks, Bonds, Deposit Accounts, Funds, Commodities, and Crypto.
* **Fixed Yields:** Automatic estimation of annual cash flow for Bonds and Deposit Accounts based on the entered interest rate.
* **Asset Allocation:** Dual view (List and Charts) with grouping by Category. Pie charts to analyze portfolio distribution by *Type* and *Sector*.


### 📊 Advanced Statistics

* **Time Filters:** Ability to filter income and expenses by **Year** and **Month**.
* **Native Charts:** Pie charts generated via `CustomPainter` (without heavy third-party libraries), featuring dynamic color palettes (shades of green for income, red/warm for expenses).

## 🛠️ Technologies Used

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **UI/UX:** Material Design 3 featuring `Scaffold`, `ModalBottomSheet`, and `SegmentedButton`.
* **Graphics:** Natively rendered on Canvas via `CustomPainter` to maximize performance.
* **Data Persistence:** `shared_preferences` for local data storage in JSON format.

## 📦 Project Structure

The source code is organized within the `lib/` folder:

* `main.dart`: Entry point of the app, data save/load logic, validation, and `NavigationBar` navigation.
* `modelli.dart`: Definition of data classes (`Conto`, `Investimento`, `Transazione`, `Prestito`).
* `home_page.dart`: Main screen and net worth calculation.
* `transazioni_page.dart`: Historical list of expenses and income.
* `portafoglio_page.dart`: Investment dashboard with tab views and allocation charts.
* `statistiche_page.dart`: Advanced analysis of transactions with time filters.
* `prestiti_page.dart`: Management of active debts and installment repayments.

## 🚀 Getting Started

1. Ensure you have the **Flutter SDK** installed and configured.
2. Clone this repository or download the project folder.
3. Open the terminal in the project's root directory and install dependencies:
```bash
flutter pub get

```


4. To launch the app in debug mode on an emulator or physical device:
```bash
flutter run

```


5. To compile the production APK (optimized and lightweight) for Android:
```bash
flutter build apk --release

```


*The generated file will be located in `build/app/outputs/flutter-apk/app-release.apk`.*
