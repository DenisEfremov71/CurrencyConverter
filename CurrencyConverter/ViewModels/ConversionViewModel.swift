//
//  ConvertViewModel.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

class ConversionViewModel: ObservableObject {
    let currencyManager: CurrencyManageable

    init(currencyManager: CurrencyManageable) {
        self.currencyManager = currencyManager
    }

    @Published var total: Double = 0
    @Published var fromCurrency: CurrencyCode = .usd
    @Published var toCurrency: CurrencyCode = .eur

    func calculateRate(fromCurrency: CurrencyCode, toCurrency: CurrencyCode, for amount: Double) {
        currencyManager.convert(fromCurrency: fromCurrency, toCurrency: toCurrency, for: amount)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.total = currencyManager.total
        }
    }

    func loadLastCurrencyPair() async throws {
        try await currencyManager.loadLastCurrencyPair(with: RateStore())
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.fromCurrency = currencyManager.lastCurrencyPair.base
            self.toCurrency = currencyManager.lastCurrencyPair.quote
        }
    }

    func saveHistory() async throws {
        try await currencyManager.saveHistory(with: HistoryStore())
    }

    func saveLastCurrencyPair() async throws {
        try await currencyManager.saveLastCurrencyPair(fromCurrency, toCurrency, with: RateStore())
    }
}
