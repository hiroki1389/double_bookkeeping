//
//  EditMemoView.swift
//  double_bookkepping
//
//  Created by Hiroki Kobayashi on 2024/07/01.
//

import SwiftUI

struct EditMemoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var data: BookkeepingData
    @State var account: Account
    @State private var memo: String

    init(account: Account) {
        _account = State(initialValue: account)
        _memo = State(initialValue: account.memo ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("科目: \(account.name)")) {
                    TextEditor(text: $memo)
                        .frame(height: 150) // 高さを調整して、複数行を表示できるようにする
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
                Button("保存") {
                    data.updateAccountMemo(account: account, newMemo: memo) // メモを保存
                    presentationMode.wrappedValue.dismiss()  // ビューを閉じる
                }
            }
            .navigationTitle("\(account.name)のメモ")
        }
    }
}
