//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var currencyManager: CurrencyManager

    var body: some View {
        TabView {
            ConvertionView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Convert")
                }

            HistoryListView()
                .tabItem {
                    Image(systemName: "list.bullet.circle.fill")
                    Text("History")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CurrencyManager.shared)
}
