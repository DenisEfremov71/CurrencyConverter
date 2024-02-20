//
//  HistoryListView.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import SwiftUI

struct HistoryListView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @StateObject var viewModel = HistoryListViewModel()
    @State private var searchText = ""
    @State private var showErrorAlert: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.transactions.reversed()
                    .filter { searchText.isEmpty ||
                        $0.description.localizedCaseInsensitiveContains(searchText) }) { transaction in
                            NavigationLink {
                                ConversionDetailsView(
                                    transactionVM: TransactionViewModel(transaction: transaction)
                                )
                            } label: {
                                Text("\(String(describing: transaction))")
                            }
                        }
            }
            .searchable(text: $searchText)
            .navigationBarBackButtonHidden()
            .navigationTitle("Conversion History")
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.getTransactions()
                } catch {}
            }
        }
        .onReceive(currencyManager.$errorMessage, perform: { _ in
            if !currencyManager.errorMessage.isEmpty {
                showErrorAlert = true
            }
        })
        .alert("Error: \(currencyManager.errorMessage)", isPresented: $showErrorAlert) {
            VStack {
                Button("Close", role: .cancel) {}
            }
        }
    }
}

#Preview {
    HistoryListView()
        .environmentObject(CurrencyManager.shared)
}
