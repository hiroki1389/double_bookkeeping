//
//  DoubleEntryBookkeepingApp.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/06/30.
//

import SwiftUI

// アプリのエントリーポイントとして定義
@main

struct DoubleBookkeepingApp: App {
    // アプリ全体で共有するインスタンス，すべてのビューで共有される
    @StateObject private var data = BookkeepingData()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                AccountListView()
                    .tabItem {
                        Label("科目", systemImage: "list.bullet")
                    }
                    .environmentObject(data) // インスタンスの各ビューでのデータ共有
                
                AddJournalEntryView()
                    .tabItem {
                        Label("仕訳追加", systemImage: "plus.circle")
                    }
                    .environmentObject(data)
                
                JournalEntriesListView()
                    .tabItem {
                        Label("仕訳一覧", systemImage: "doc.text")
                    }
                    .environmentObject(data)
                
                MonthlySummaryView()
                    .tabItem {
                        Label("月次集計", systemImage: "calendar")
                    }
                    .environmentObject(data)
            }
        }
    }
}
