//
//  ContentView.swift
//  Expense tracker
//
//  Created by Rishi on 01/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var showingAddExpense = false
    @State private var showingSettingsSheet = false
    
    var body: some View {
        TabView {
            ExpensesListView(viewModel: viewModel, showingAddExpense: $showingAddExpense)
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
            
            AnalyticsView(viewModel: viewModel)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(viewModel: viewModel)
        }
    }
}

struct ExpensesListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Binding var showingAddExpense: Bool
    
    var body: some View {
        NavigationView {
            List {
                // Monthly summary section
                Section {
                    HStack {
                        Text("Total Expenses")
                        Spacer()
                        Text("$\(viewModel.totalExpenses, specifier: "%.2f")")
                            .fontWeight(.bold)
                    }
                    
                    if let limit = viewModel.monthlyLimit {
                        HStack {
                            Text("Monthly Budget")
                            Spacer()
                            Text("$\(limit, specifier: "%.2f")")
                                .foregroundColor(viewModel.isOverBudget ? .red : .green)
                        }
                    }
                }
                
                // Expenses list
                Section {
                    ForEach(viewModel.expenses.sorted(by: { $0.date > $1.date })) { expense in
                        ExpenseRow(expense: expense)
                    }
                    .onDelete(perform: viewModel.removeExpense)
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            Image(systemName: expense.category.icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading) {
                Text(expense.title)
                    .font(.headline)
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(expense.amount, specifier: "%.2f")")
                    .font(.headline)
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ContentView()
}
