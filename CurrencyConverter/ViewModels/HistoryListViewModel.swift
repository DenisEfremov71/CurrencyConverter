//
//  HistoryListViewModel.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

class HistoryListViewModel: ObservableObject {
    let currencyManager: CurrencyManageable

    init(currencyManager: CurrencyManageable) {
        self.currencyManager = currencyManager
    }

    @Published var transactions: [Transaction] = []

    func getTransactions() async throws {
        try await currencyManager.loadHistory(with: HistoryStore())
        if !currencyManager.history.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.transactions = currencyManager.history
            }
        }
    }
}
