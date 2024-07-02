//
//  Account.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/06/30.
//

import Foundation

// 勘定科目の種類を定義
enum AccountType: String, CaseIterable, Identifiable, Codable {
    case asset = "資産"
    case liability = "負債"
    case equity = "純資産"
    case expense = "費用"
    case revenue = "収益"
    case pl = "損益"
    
    var id: String { self.rawValue }
}

// 勘定科目を定義
struct Account: Identifiable, Hashable, Codable {
    let id = UUID() // Universally Unique Identifierの略，これによって128ビットの一意な識別子を与える
    let name: String
    let type: AccountType
    var memo: String? // 科目のメモ
    var isArchived: Bool = false // アーカイブ状態を追加
    
    // アーカイブされてない場合はtrueを返す
    var isActive: Bool {
        !isArchived
    }
}

// 仕訳の借方の定義
struct DebitEntry: Identifiable, Codable {
    var id = UUID()
    var account: Account
    var amount: Int
}

// 仕訳の貸方の定義
struct CreditEntry: Identifiable, Codable {
    var id = UUID()
    var account: Account
    var amount: Int
}

// 仕訳を定義
struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var debitAccounts: [DebitEntry] // 配列として定義
    var creditAccounts: [CreditEntry]
    var description: String
}

