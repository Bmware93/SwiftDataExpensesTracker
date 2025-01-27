//
//  DonutChartFunctions.swift
//  SwiftDataExpensesTracker
//
//  Created by Benia Morgan-Ware on 1/26/25.
//

import Foundation

func getTodayCategoryTotals(from expenses: [Expense]) -> [CategoryTotal] {
    // Get today's date components
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    
    // Filter expenses to include only those made today
    let todayExpenses = expenses.filter { expense in
        let expenseDate = calendar.startOfDay(for: expense.date)
        return expenseDate == today
    }
    
    // Group and sum expenses by category
    let categoryTotals = Dictionary(grouping: todayExpenses, by: { $0.category })
        .map { category, expenses in
            CategoryTotal(category: category, total: expenses.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.total > $1.total } // Sort by total in descending order

    return categoryTotals
}

func getWeekCategoryTotals(from expenses: [Expense]) -> [CategoryTotal] {
    let calendar = Calendar.current
    let now = Date()

    // Get the start and end of the current week
    guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
          let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
        return []
    }

    // Filter expenses that fall within the current week
    let weekExpenses = expenses.filter { expense in
        expense.date >= weekStart && expense.date <= weekEnd
    }

    // Group and sum expenses by category
    let categoryTotals = Dictionary(grouping: weekExpenses, by: { $0.category })
        .map { category, expenses in
            CategoryTotal(category: category, total: expenses.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.total > $1.total } // Sort by total in descending order

    return categoryTotals
}

func getMonthCategoryTotals(from expenses: [Expense]) -> [CategoryTotal] {
    let calendar = Calendar.current
    let now = Date()
    
    // Get the start and end of the current month
    guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
          let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
        return []
    }

    // Filter expenses within the current month
    let monthExpenses = expenses.filter { expense in
        expense.date >= monthStart && expense.date <= monthEnd
    }

    // Group and sum expenses by category
    let categoryTotals = Dictionary(grouping: monthExpenses, by: { $0.category })
        .map { category, expenses in
            CategoryTotal(category: category, total: expenses.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.total > $1.total } 

    return categoryTotals
}

func getYearCategoryTotals(from expenses: [Expense]) -> [CategoryTotal] {
    let calendar = Calendar.current
    let now = Date()
    
    // Get the start of the current year
    let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
    
    // Get the end of the current year
    let yearEnd = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: yearStart)!
    
    // Filter expenses within the current year
    let yearExpenses = expenses.filter { expense in
        expense.date >= yearStart && expense.date <= yearEnd
    }

    // Group, sum, and sort expenses by category totals
    let categoryTotals = Dictionary(grouping: yearExpenses, by: { $0.category })
        .map { category, expenses in
            CategoryTotal(category: category, total: expenses.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.total > $1.total }

    return categoryTotals
}


