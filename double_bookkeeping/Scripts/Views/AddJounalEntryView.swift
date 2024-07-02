//
//  AddJournalEntryView.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/06/30.
//

import SwiftUI

struct AddJournalEntryView: View {
    @EnvironmentObject var data: BookkeepingData // 環境オブジェクトとして提供

    @State private var date = Date()
    @State private var debitAccounts: [DebitEntry] = [DebitEntry(account: Account(name: "現金", type: .asset), amount: 0)]
    @State private var creditAccounts: [CreditEntry] = [CreditEntry(account: Account(name: "現金", type: .asset), amount: 0)]
    @State private var description = ""
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            Form {
                DatePicker("日付", selection: $date, displayedComponents: .date)

                Section(header: Text("借方科目")) {
                    ForEach(debitAccounts.indices, id: \.self) { index in
                        HStack {
                            Picker("科目", selection: $debitAccounts[index].account) {
                                ForEach(data.accounts.filter { $0.isActive }) { account in
                                    Text(account.name).tag(account as Account)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            TextField("金額", value: $debitAccounts[index].amount, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteDebitAccount(at: index)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                    Button(action: addDebitAccount) {
                        Text("借方科目を追加")
                    }
                }

                Section(header: Text("貸方科目")) {
                    ForEach(creditAccounts.indices, id: \.self) { index in
                        HStack {
                            Picker("科目", selection: $creditAccounts[index].account) {
                                ForEach(data.accounts.filter { $0.isActive }) { account in
                                    Text(account.name).tag(account as Account)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            TextField("金額", value: $creditAccounts[index].amount, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteCreditAccount(at: index)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                    Button(action: addCreditAccount) {
                        Text("貸方科目を追加")
                    }
                }

                TextField("摘要を入力", text: $description)

                Button("追加") {
                    if !validateAmounts() {
                        showErrorAlert = true
                    } else {
                        addJournalEntry()
                    }
                }
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("エラー"), message: Text("貸方と借方の合計金額が一致していません"), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("仕訳追加")
        }
    }

    func addDebitAccount() {
        debitAccounts.append(DebitEntry(account: Account(name: "現金", type: .asset), amount: 0))
    }

    func addCreditAccount() {
        creditAccounts.append(CreditEntry(account: Account(name: "現金", type: .asset), amount: 0))
    }

    func deleteDebitAccount(at index: Int) {
        debitAccounts.remove(at: index)
    }

    func deleteCreditAccount(at index: Int) {
        creditAccounts.remove(at: index)
    }

    func validateAmounts() -> Bool {
        let debitTotal = debitAccounts.map { $0.amount }.reduce(0, +)
        let creditTotal = creditAccounts.map { $0.amount }.reduce(0, +)
        return debitTotal == creditTotal && debitTotal > 0 && creditTotal > 0
    }

    func addJournalEntry() {
        data.addJournalEntry(date: date, debitAccounts: debitAccounts, creditAccounts: creditAccounts, description: description)
        debitAccounts = [DebitEntry(account: Account(name: "現金", type: .asset), amount: 0)]
        creditAccounts = [CreditEntry(account: Account(name: "現金", type: .asset), amount: 0)]
        description = ""
        date = Date()
    }
}
