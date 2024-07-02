//
//  BookkeepingData.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/06/30.
//

import Foundation
import Combine

class BookkeepingData: ObservableObject, Codable {
    // 科目の一覧
    // @publishedを使うことで更新を自動にする
    @Published var accounts: [Account] = [
        Account(name: "現金", type: .asset),
        Account(name: "奨学金", type: .liability),
        Account(name: "純資産", type: .equity),
        Account(name: "食費", type: .expense),
        Account(name: "給与", type: .revenue),
        Account(name: "損益", type: .pl)
    ]
    
    @Published var journalEntries: [JournalEntry] = [] // 仕訳の一覧
    
    enum CodingKeys: String, CodingKey {
        case accounts
        case journalEntries
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accounts = try container.decode([Account].self, forKey: .accounts)
        journalEntries = try container.decode([JournalEntry].self, forKey: .journalEntries)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts, forKey: .accounts)
        try container.encode(journalEntries, forKey: .journalEntries)
    }
    
    init() {
        loadData()
    }
    
    // データを UserDefaults に保存
    func saveData() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "BookkeepingData")
        }
    }
    
    // UserDefaults からデータを読み込む
    func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: "BookkeepingData"),
           let decodedData = try? JSONDecoder().decode(BookkeepingData.self, from: savedData) {
            self.accounts = decodedData.accounts
            self.journalEntries = decodedData.journalEntries
        }
    }

    // 新しい勘定科目を追加
    func addAccount(name: String, type: AccountType, memo: String?) {
        let newAccount = Account(name: name, type: type, memo: memo)
        accounts.append(newAccount)
        saveData()
    }

    // 勘定科目のメモを更新
    func updateAccountMemo(account: Account, newMemo: String) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index].memo = newMemo
            saveData()
        }
    }
    
    // 勘定科目のアーカイブ
    func archiveAccount(account: Account) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[index].isArchived = true
        saveData()
    }
    
    // アーカイブされた勘定科目を戻す
    func unarchiveAccount(account: Account) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[index].isArchived = false
        saveData()
    }
    
    // 勘定科目の削除
    func deleteAccount(account: Account) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts.remove(at: index)
        saveData()
    }
    
    // アーカイブされた科目一覧を取得
    func getArchivedAccounts() -> [Account] {
        accounts.filter { $0.isArchived }
    }
    
    // 並び順を保存するメソッド
   func saveAccountOrder() {
       // ここで並び順を保存する処理を実装する
       // 例としてUserDefaultsに保存する場合
       let order = accounts.map { $0.id.uuidString }
       UserDefaults.standard.set(order, forKey: "accountOrder")
       saveData()
   }
   
   // 並び順をロードするメソッド
   func loadAccountOrder() {
       // ここで並び順をロードする処理を実装する
       if let order = UserDefaults.standard.array(forKey: "accountOrder") as? [String] {
           let sortedAccounts = order.compactMap { id in
               accounts.first { $0.id.uuidString == id }
           }
           accounts = sortedAccounts + accounts.filter { !order.contains($0.id.uuidString) }
       }
   }
    
    // 仕訳の追加
    func addJournalEntry(
        date: Date,
        debitAccounts: [DebitEntry],
        creditAccounts: [CreditEntry],
        description: String) {
        let debitTotal = debitAccounts.map { $0.amount }.reduce(0, +)
        let creditTotal = creditAccounts.map { $0.amount }.reduce(0, +)
        
        guard debitTotal == creditTotal else {
            print("Error: 借方と貸方の合計金額が一致していません。")
            print("借方合計金額: \(debitTotal), 貸方合計金額: \(creditTotal)")
            return
        }
    
        let newEntry = JournalEntry(date: date, debitAccounts: debitAccounts, creditAccounts: creditAccounts, description: description)
        journalEntries.append(newEntry)
        saveData() // 仕訳が追加されるたびに保存
        print("仕訳が追加されました: \(newEntry)")
    }
}
