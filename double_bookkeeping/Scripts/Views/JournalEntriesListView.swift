//
//  JournalEntriesListView.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/06/30.
//

import SwiftUI

struct JournalEntriesListView: View {
    @EnvironmentObject var data: BookkeepingData
    @State private var selectedAccount: Account?
    @State private var isSelectionMode = false
    @State private var selectedEntries = Set<UUID>()
    @State private var sortOption: SortOption = .addedAscending
    @State private var selectedEntry: JournalEntry?
    @State private var showEditView = false

    enum SortOption: String, CaseIterable, Identifiable {
        case addedAscending = "追加順昇順"
        case addedDescending = "追加順降順"
        case dateAscending = "日付昇順"
        case dateDescending = "日付降順"

        var id: SortOption { self }
    }

    var sortedEntries: [JournalEntry] {
        var entries = filteredEntries

        switch sortOption {
        case .addedAscending:
            entries.sort { $0.id < $1.id }
        case .addedDescending:
            entries.sort { $0.id > $1.id }
        case .dateAscending:
            entries.sort { $0.date < $1.date }
        case .dateDescending:
            entries.sort { $0.date > $1.date }
        }

        return entries
    }

    var filteredEntries: [JournalEntry] {
        if let account = selectedAccount {
            let entries = data.journalEntries.filter { entry in
                entry.debitAccounts.contains { $0.account.id == account.id } ||
                entry.creditAccounts.contains { $0.account.id == account.id }
            }
            print("Selected account: \(account.name)")
            print("Filtered entries count: \(entries.count)")
            return entries
        }
        return data.journalEntries
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("科目で絞り込み", selection: $selectedAccount) {
                    Text("全ての仕訳").tag(Account?.none)
                    ForEach(data.accounts) { account in
                        Text(account.name).tag(account as Account?)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("並び替え", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    ForEach(sortedEntries) { entry in
                        HStack {
                            if isSelectionMode {
                                Button(action: {
                                    if selectedEntries.contains(entry.id) {
                                        selectedEntries.remove(entry.id)
                                    } else {
                                        selectedEntries.insert(entry.id)
                                    }
                                }) {
                                    Image(systemName: selectedEntries.contains(entry.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(.blue)
                                }
                            }

                            VStack(alignment: .leading) {
                                Text("日付: \(entry.date, formatter: dateFormatter)")
                                VStack(alignment: .leading) {
                                    Text("借方:")
                                        .foregroundColor(.blue)
                                    ForEach(entry.debitAccounts, id: \.account.id) { debit in
                                        HStack(spacing: 0) {
                                            Text(debit.account.name)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(1)  // 行数を1に制限
                                            Text("\(debit.amount)円")
                                                .frame(width: 100, alignment: .trailing)
                                                .lineLimit(1)  // 行数を1に制限
                                        }
                                    }
                                    Text("貸方:")
                                        .foregroundColor(.red)
                                    ForEach(entry.creditAccounts, id: \.account.id) { credit in
                                        HStack(spacing: 0) {
                                            Text(credit.account.name)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(1)  // 行数を1に制限
                                            Text("\(credit.amount)円")
                                                .frame(width: 100, alignment: .trailing)
                                                .lineLimit(1)  // 行数を1に制限
                                        }
                                    }
                                }
                                Text("適用:")
                                    .foregroundColor(.green)  // 摘要のラベルに緑色を設定
                                    + Text(" \(entry.description)")
                                    .foregroundColor(.primary)  // 摘要の内容はデフォルトの色
                            }
                            .contentShape(Rectangle()) // タップ領域を広げる
                            .onTapGesture {
                                if !isSelectionMode {
                                    selectedEntry = entry
                                    showEditView = true
                                } else {
                                    if selectedEntries.contains(entry.id) {
                                        selectedEntries.remove(entry.id)
                                    } else {
                                        selectedEntries.insert(entry.id)
                                    }
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteEntry(entry)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isSelectionMode {
                            Button("キャンセル") {
                                isSelectionMode = false
                                selectedEntries.removeAll()
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isSelectionMode {
                            Button("削除") {
                                deleteSelectedEntries()
                            }
                        } else {
                            Button("選択") {
                                isSelectionMode = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("仕訳一覧")
            .sheet(isPresented: $showEditView) {
                if let entry = selectedEntry {
                    EditJournalEntryView(entry: entry)
                }
            }
        }
    }

    func deleteEntry(_ entry: JournalEntry) {
        if let index = data.journalEntries.firstIndex(where: { $0.id == entry.id }) {
            data.journalEntries.remove(at: index)
            data.saveData() // データを保存
        }
    }

    func deleteSelectedEntries() {
        for id in selectedEntries {
            if let index = data.journalEntries.firstIndex(where: { $0.id == id }) {
                data.journalEntries.remove(at: index)
            }
        }
        data.saveData() // データを保存
        selectedEntries.removeAll()
        isSelectionMode = false
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()
