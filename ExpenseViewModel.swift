import Foundation
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var monthlyLimit: Double? {
        didSet {
            UserDefaults.standard.set(monthlyLimit, forKey: "MonthlyLimit")
        }
    }
    
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedExpenses")
    
    init() {
        loadData()
        monthlyLimit = UserDefaults.standard.object(forKey: "MonthlyLimit") as? Double
    }
    
    // MARK: - Computed Properties
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var currentMonthExpenses: Double {
        monthlyExpenses(for: Date())
    }
    
    var monthlyProgress: Double {
        guard let limit = monthlyLimit, limit > 0 else { return 0 }
        return min(currentMonthExpenses / limit, 1.0)
    }
    
    var isOverBudget: Bool {
        guard let limit = monthlyLimit else { return false }
        return currentMonthExpenses > limit
    }
    
    // MARK: - Category Analysis
    
    func categoryTotal(_ category: Expense.Category) -> Double {
        expenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    func categoryPercentage(_ category: Expense.Category) -> Double {
        guard totalExpenses > 0 else { return 0 }
        return (categoryTotal(category) / totalExpenses) * 100
    }
    
    // MARK: - Monthly Analysis
    
    func monthlyExpenses(for date: Date) -> Double {
        expenses
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    func expensesForLast6Months() -> [(month: String, amount: Double)] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        return (0..<6).map { monthsAgo -> (String, Double) in
            let date = calendar.date(byAdding: .month, value: -monthsAgo, to: currentDate)!
            let monthName = date.formatted(.dateTime.month(.abbreviated))
            let amount = monthlyExpenses(for: date)
            return (monthName, amount)
        }.reversed()
    }
    
    // MARK: - CRUD Operations
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveData()
    }
    
    func removeExpense(at indexSet: IndexSet) {
        expenses.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(expenses)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data: \(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        do {
            let data = try Data(contentsOf: savePath)
            expenses = try JSONDecoder().decode([Expense].self, from: data)
        } catch {
            expenses = []
        }
    }
}

// MARK: - FileManager Extension
extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
} 