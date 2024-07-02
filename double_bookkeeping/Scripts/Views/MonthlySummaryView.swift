//
//  MonthlySummaryView.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/06/30.
//

import SwiftUI

struct MonthlySummaryView: View {
    @EnvironmentObject var data: BookkeepingData
    
    @State private var selectedMonth = Calendar.current.dateComponents([.year, .month], from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    enum SummaryTab: String, CaseIterable, Identifiable {
        case balanceSheet = "貸借対照表"
        case profitLossStatement = "損益計算書"
        
        var id: SummaryTab { self }
    }
    
    func calculateMonthlySummary(for month: DateComponents) -> [AccountType: [String: Int]] {
        var summary: [AccountType: [String: Int]] = [:]
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: month)!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        for entry in data.journalEntries where entry.date >= startOfMonth && entry.date < endOfMonth {
            for debit in entry.debitAccounts {
                summary[debit.account.type, default: [:]][debit.account.name, default: 0] += debit.amount
            }
            for credit in entry.creditAccounts {
                summary[credit.account.type, default: [:]][credit.account.name, default: 0] -= credit.amount
            }
        }
        
        return summary
    }
    
    func calculateTotalAmount(for type: AccountType) -> Int {
        let accounts = calculateMonthlySummary(for: selectedMonth)[type] ?? [:]
        let total = accounts.values.reduce(0, +)
        return total
    }
    
    func displayColor(for accountType: AccountType, amount: Int) -> Color {
        switch accountType {
        case .asset:
            return amount < 0 ? .red : .primary
        case .liability:
            return amount > 0 ? .red : .primary
        case .equity:
            return amount > 0 ? .red : .primary
        case .expense:
            return amount < 0 ? .red : .primary
        case .revenue:
            return amount > 0 ? .red : .primary
        case .pl:
            return amount < 0 ? .red : .primary
        }
    }
    
    var body: some View {
        TabView {
            VStack {
                // 年と月を選択するピッカー
                HStack {
                    Picker("年を選択", selection: $selectedYear) {
                        ForEach(2023...2030, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 100)
                    .onChange(of: selectedYear) { newYear in
                        selectedMonth.year = newYear
                    }
                    
                    Picker("月を選択", selection: $selectedMonth) {
                        ForEach(1..<13) { month in
                            let dateComponents = DateComponents(year: selectedMonth.year, month: month)
                            let monthName = DateFormatter.localizedString(from: Calendar.current.date(from: dateComponents)!, dateStyle: .none, timeStyle: .none)
                            Text("\(month)月").tag(dateComponents)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80) // 月選択の幅を調整
                    .onChange(of: selectedMonth) { newMonth in
                        selectedMonth.month = newMonth.month
                        selectedMonth.year = newMonth.year
                    }
                }
                .padding()
                
                List {
                    ForEach([AccountType.asset, .liability, .equity], id: \.self) { type in
                        Section(header: Text(type.rawValue)) {
                            ForEach(calculateMonthlySummary(for: selectedMonth)[type]?.sorted(by: { $0.key < $1.key }) ?? [], id: \.key) { accountName, amount in
                                HStack {
                                    Text(accountName)
                                    Spacer()
                                    Text("\(abs(amount), specifier: "%d")円")
                                        .foregroundColor(displayColor(for: type, amount: amount))
                                }
                            }
                            HStack {
                                Text("合計")
                                    .bold()
                                Spacer()
                                Text("\(abs(calculateTotalAmount(for: type)), specifier: "%d")円")
                                    .foregroundColor(displayColor(for: type, amount: calculateTotalAmount(for: type)))
                            }
                        }
                    }
                }
                .navigationTitle("貸借対照表")
            }
            .tabItem {
                Label("貸借対照表", systemImage: "folder")
            }
            
            VStack {
                // 年と月を選択するピッカー
                HStack {
                    Picker("年を選択", selection: $selectedYear) {
                        ForEach(2023...2030, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 100)
                    .onChange(of: selectedYear) { newYear in
                        selectedMonth.year = newYear
                    }
                    
                    Picker("月を選択", selection: $selectedMonth) {
                        ForEach(1..<13) { month in
                            let dateComponents = DateComponents(year: selectedMonth.year, month: month)
                            let monthName = DateFormatter.localizedString(from: Calendar.current.date(from: dateComponents)!, dateStyle: .none, timeStyle: .none)
                            Text("\(month)月").tag(dateComponents)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80) // 月選択の幅を調整
                    .onChange(of: selectedMonth) { newMonth in
                        selectedMonth.month = newMonth.month
                        selectedMonth.year = newMonth.year
                    }
                }
                .padding()
                
                List {
                    ForEach([AccountType.expense, .revenue, .pl], id: \.self) { type in
                        Section(header: Text(type.rawValue)) {
                            ForEach(calculateMonthlySummary(for: selectedMonth)[type]?.sorted(by: { $0.key < $1.key }) ?? [], id: \.key) { accountName, amount in
                                HStack {
                                    Text(accountName)
                                    Spacer()
                                    Text("\(abs(amount), specifier: "%d")円")
                                        .foregroundColor(displayColor(for: type, amount: amount))
                                }
                            }
                            HStack {
                                Text("合計")
                                    .bold()
                                Spacer()
                                Text("\(abs(calculateTotalAmount(for: type)), specifier: "%d")円")
                                    .foregroundColor(displayColor(for: type, amount: calculateTotalAmount(for: type)))
                            }
                        }
                    }
                }
                .navigationTitle("損益計算書")
            }
            .tabItem {
                Label("損益計算書", systemImage: "doc.text")
            }
        }
    }
}
