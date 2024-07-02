//
//  AccountListView.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/06/30.
//

import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var data: BookkeepingData
    
    @State private var newAccountName = "" // ユーザが勘定科目名を入力する変数
    @State private var selectedAccountType: AccountType = .asset // ユーザが勘定科目の種類を入力する変数
    @State private var selectedAccount: Account?
    @State private var newMemo = ""

    enum ListTab: String, CaseIterable, Identifiable {
        case active = "有効な科目"
        case archived = "アーカイブされた科目"
        
        var id: ListTab { self }
    }
    
    @State private var selectedTab: ListTab = .active
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                VStack {
                    List {
                        ForEach(data.accounts.filter { $0.isActive }) { account in
                            HStack {
                                Text(account.name)
                                Spacer()
                                Text(account.type.rawValue)
                            }
                            .contentShape(Rectangle()) // タップエリアを拡大
                            .onTapGesture {
                                selectedAccount = account
                                newMemo = account.memo ?? ""
                            }
                            .swipeActions {
                                Button("アーカイブ") {
                                    archiveAccount(account: account)
                                }
                                .tint(.orange)
                            }
                        }
                        .onMove(perform: moveAccount)
                        
                        HStack {
                            TextField("新しい科目", text: $newAccountName) // 新しい科目の名前を入力するフィールド
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // スタイルを適用
                            Picker("", selection: $selectedAccountType) { // 勘定科目の種類を選択するピッカー
                                ForEach(AccountType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle()) // メニュー形式のピッカーにする
                            Button("追加") {
                                addAccount() // 科目追加ボタンが押された時の処理
                                print("科目追加ボタンが押されました") // デバッグメッセージ
                            }
                        }
                        .padding() // 少しパディングを追加してレイアウトを調整
                    }
                    .navigationTitle("科目リスト")
                    .toolbar {
                        EditButton()
                    }
                    .sheet(item: $selectedAccount) { account in
                        EditMemoView(account: account)
                            .environmentObject(data)
                    }
                }
                .tabItem {
                    Label("有効な科目", systemImage: "folder")
                }
                .tag(ListTab.active)
                
                VStack {
                    List {
                        ForEach(data.getArchivedAccounts()) { account in
                            HStack {
                                Text(account.name)
                                Spacer()
                                Text(account.type.rawValue)
                            }
                            .swipeActions {
                                Button("戻す") {
                                    unarchiveAccount(account: account)
                                }
                                .tint(.blue)
                                
                                Button("削除") {
                                    deleteAccount(account: account)
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .navigationTitle("アーカイブされた科目")
                }
                .tabItem {
                    Label("アーカイブされた科目", systemImage: "archivebox")
                }
                .tag(ListTab.archived)
            }
        }
    }
    
    // 科目のアーカイブ
    func archiveAccount(account: Account) {
        data.archiveAccount(account: account)
        saveOrder()
    }
    
    // 科目の元に戻す
    func unarchiveAccount(account: Account) {
        data.unarchiveAccount(account: account)
        saveOrder()
    }
    
    // 科目の完全削除
    func deleteAccount(account: Account) {
        data.deleteAccount(account: account)
        saveOrder()
    }
    
    // 科目の追加
    func addAccount() {
        guard !newAccountName.isEmpty else {
            print("科目名が空です") // デバッグメッセージ
            return
        }
        
        // 重複する科目がないか確認
        if data.accounts.contains(where: { $0.name == newAccountName && $0.type == selectedAccountType }) {
            print("この科目はすでに存在します") // デバッグメッセージ
            return
        }
        
        data.addAccount(name: newAccountName, type: selectedAccountType, memo: nil) // 新しい科目を追加
        print("科目が追加されました: \(newAccountName), \(selectedAccountType.rawValue)") // デバッグメッセージ
        newAccountName = "" // 入力フィールドをクリア
        saveOrder()
    }
    
    // 科目の並び替え
    func moveAccount(from source: IndexSet, to destination: Int) {
        data.accounts.move(fromOffsets: source, toOffset: destination)
        saveOrder()
    }
    
    // 並び順を保存する
    func saveOrder() {
        data.saveAccountOrder()
    }
}
