//
//  RatePersistableMock.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation
@testable import CurrencyConverter

class RatePersistableMock: RatePersistable {
    var rates: [CurrencyPair] = []
    var lastCurrencyPair: CurrencyPair?

    var loadRatesCalled = false
    var saveRatesCalled = false
    var loadLastCurrencyPairCalled = false
    var saveLastCurrencyPairCalled = false

    func loadRates() async throws {
        loadRatesCalled = true
        rates = [CurrencyPair.placeholder]
    }

    func saveRates(rates: [CurrencyPair]) async throws {
        saveRatesCalled = true
    }

    func loadLastCurrencyPair() async throws {
        loadLastCurrencyPairCalled = true
        lastCurrencyPair = CurrencyPair.placeholder
    }

    func saveLastCurrencyPair(_ currencyPair: CurrencyPair) async throws {
        saveLastCurrencyPairCalled = true
    }
}
