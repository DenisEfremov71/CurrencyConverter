//
//  CurrencyManagerMock.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation
@testable import CurrencyConverter

class CurrencyManagerMock: CurrencyManageable {
    var exchangeRates: [CurrencyPair] = []
    var lastCurrencyPair: CurrencyPair = CurrencyPair.placeholder
    var history: [Transaction] = []
    var errorMessage: String = ""
    var total: Double = 0.0

    var convertCalled = false
    var loadLastCurrencyPairCalled = false
    var saveLastCurrencyPairCalled = false
    var loadHistoryCalled = false
    var saveHistoryCalled = false

    func convert(fromCurrency: CurrencyConverter.CurrencyCode, toCurrency: CurrencyConverter.CurrencyCode, for amount: Double = 1.0) {
        guard !exchangeRates.isEmpty else { return }

        let rate = exchangeRates.getCrossRate(fromCurrency, toCurrency)
        total = rate * amount

        convertCalled = true
    }
    
    func loadLastCurrencyPair(with ratePersistable: CurrencyConverter.RatePersistable) async throws {
        loadLastCurrencyPairCalled = true
    }
    
    func saveLastCurrencyPair(_ base: CurrencyConverter.CurrencyCode, _ quote: CurrencyConverter.CurrencyCode, with ratePersistable: CurrencyConverter.RatePersistable) async throws {
        saveLastCurrencyPairCalled = true
    }
    
    func loadHistory(with historyPersistable: CurrencyConverter.HistoryPersistable) async throws {
        loadHistoryCalled = true
    }
    
    func saveHistory(with historyPersistable: CurrencyConverter.HistoryPersistable) async throws {
        saveHistoryCalled = true
    }
}
