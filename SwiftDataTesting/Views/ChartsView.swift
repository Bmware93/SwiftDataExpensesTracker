//
//  ChartsView.swift
//  SwiftDataExpensesTracker
//
//  Created by Benia Morgan-Ware on 1/29/24.
//

import SwiftUI
import Charts
import SwiftData


struct ChartsView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \Expense.date) var expenses: [Expense]
    @State private var barGraphIsAnimating = false
    @State private var donutGraphIsAnimating = false
    @State private var barGraphPicker: TimePeriods = .year
    
    
    func getMonthlyExpenseSum() -> TransactionGroup {
        guard !expenses.isEmpty else { return [:] }
        
        var groupedExpenses = TransactionGroup()
        
        for expense in expenses {
            //Getting the month from the expense
            //Short month is the abbreviated version
            let month = expense.shortMonth
            
            // If the month is already a key in the dictionary, append the expense to the existingGrp array
            // and update the sum of values
            if var existingGroup = groupedExpenses[month] {
                existingGroup.expenses.append(expense)
                existingGroup.sum += expense.amount
                
                groupedExpenses[month] = existingGroup
            } else {
                // If the month is not a key in the dictionary, create a new entry with the expense in an array
                // and set the sum of values to the expense value
                groupedExpenses[month] = (expenses: [expense] , sum: expense.amount)
            }
        }
        return groupedExpenses
    }
    
    var categoryTotals: [SpendingCategory: Double] {
        Dictionary(grouping: expenses, by: {$0.category})
            .mapValues{$0.reduce(0) {$0 + $1.amount }}
    }
    
    var topCategoryTotals: [CategoryTotal] {
        categoryTotals
            .map { CategoryTotal(category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total } // Sorting to get the highest totals
            .prefix(4) // Taking only the top 4
            .map { $0 } // Map to array
    }
    
    
    //Converting above dictionary to an array of CategoryTotal objects.
    var categoryTotalData: [CategoryTotal] {
        categoryTotals.map { CategoryTotal(category: $0.key, total: $0.value) }
    }
    
    //Time periods for picker in graph view
    //Will adjust based on how user wants to view their spending
    enum TimePeriods: String, CaseIterable, Identifiable {
        case day   = "Today"
        case week  = "This Week"
        case month = "This Month"
        case year  = "This Year"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if expenses.isEmpty {
                    
                    ContentUnavailableView {
                        Label("No Data", systemImage: "creditcard.trianglebadge.exclamationmark")
                    } description: {
                        Text("Start adding expenses to see a summary of your monthly spending")
                    }
                    .offset(y: -60)
                    
                } else {
                    
                    VStack {
                        Form {
                            
                            let groupedExpenses = getMonthlyExpenseSum()
                            
                            HStack {
                                Menu {
                                    ForEach(TimePeriods.allCases, id: \.self) { option in
                                        Button {
                                            self.barGraphPicker = option
                                        } label: {
                                            Label(option.rawValue, systemImage: "")
                                        }
                                        
                                    }
                                    
                                } label: {
                                    Text(barGraphPicker.rawValue)
                                        .font(.system(size: 18))
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                }
                                .foregroundStyle(.primary)
                                
                                
                                
                                Spacer()
                                
                                VStack(spacing: -10) {
                                    Text(currencyFormat(value: groupedExpenses.values.reduce(0) { $0 + $1.sum }))
                                        .padding(.bottom)
                                        .font(.headline)
                                        .bold()
                                    
                                    Text("Total Spent")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                }
                            }
                            .padding(.bottom, 25)
                            
                            //MARK: Bar Chart starts here
                            BarChartView(groupedExpenses: groupedExpenses)
                            
                            
                            DisclosureGroup("Spending Insights") {
                                VStack {
                                    HStack {
                                        Text("Top Spending by Category")
                                        
                                    }
                                    //MARK: Donut Chart starts here
                                    DonutChartView(categoryTotals: topCategoryTotals)
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                    
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Summary")
        }
    }
}


#Preview {
    let preview = previewContainer([Expense.self])
    return ChartsView().modelContainer(preview.container)
}


