//
//  EditJournalEntryView.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/07/01.
//

import SwiftUI

struct EditJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var data: BookkeepingData
    @State var entry: JournalEntry
    @State private var debitAccounts: [DebitEntry]
    @State private var creditAccounts: [CreditEntry]
    @State private var description: String
    @State private var showErrorAlert = false

    init(entry: JournalEntry) {
        _entry = State(initialValue: entry)
        _debitAccounts = State(initialValue: entry.debitAccounts)
        _creditAccounts = State(initialValue: entry.creditAccounts)
        _description = State(initialValue: entry.description)
    }

    var body: some View {
        NavigationView {
            Form {
                DatePicker("日付", selection: $entry.date, displayedComponents: .date)
                
                Section(header: Text("借方科目")) {
                    ForEach(debitAccounts.indices, id: \.self) { index in
                        HStack {
                            Picker("科目", selection: $debitAccounts[index].account) {
                                ForEach(data.accounts) { account in
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
                    Button(action: { addDebitAccount() }) {
                        Text("借方科目を追加")
                    }
                }

                Section(header: Text("貸方科目")) {
                    ForEach(creditAccounts.indices, id: \.self) { index in
                        HStack {
                            Picker("科目", selection: $creditAccounts[index].account) {
                                ForEach(data.accounts) { account in
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
                    Button(action: { addCreditAccount() }) {
                        Text("貸方科目を追加")
                    }
                }

                TextField("摘要を入力", text: $description)
            }
            .navigationTitle("仕訳編集")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        if !validateAmounts() {
                            showErrorAlert = true
                        } else {
                            updateJournalEntry()
                        }
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("エラー"), message: Text("貸方と借方の合計金額が一致していません"), dismissButton: .default(Text("OK")))
            }
        }
    }

    func addDebitAccount() {
        debitAccounts.append(DebitEntry(account: data.accounts.first ?? Account(name: "現金", type: .asset), amount: 0))
    }

    func addCreditAccount() {
        creditAccounts.append(CreditEntry(account: data.accounts.first ?? Account(name: "現金", type: .asset), amount: 0))
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

    func updateJournalEntry() {
        if let index = data.journalEntries.firstIndex(where: { $0.id == entry.id }) {
            data.journalEntries[index] = JournalEntry(id: entry.id, date: entry.date, debitAccounts: debitAccounts, creditAccounts: creditAccounts, description: description)
            data.saveData() // データを保存
            presentationMode.wrappedValue.dismiss()  // 保存後にビューを閉じる
        }
    }
}
