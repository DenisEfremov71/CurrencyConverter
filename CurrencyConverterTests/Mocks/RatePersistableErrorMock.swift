//
//  RatePersistableErrorMock.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation
@testable import CurrencyConverter

class RatePersistableErrorMock: RatePersistable {
    var rates: [CurrencyPair] = []
    var lastCurrencyPair: CurrencyPair?

    var loadRatesCalled = false
    var saveRatesCalled = false
    var loadLastCurrencyPairCalled = false
    var saveLastCurrencyPairCalled = false

    func loadRates() async throws {
        loadRatesCalled = true
        throw RateStoreError.badURL
    }

    func saveRates(rates: [CurrencyPair]) async throws {
        saveRatesCalled = true
        throw RateStoreError.failedToEncodeRates
    }

    func loadLastCurrencyPair() async throws {
        loadLastCurrencyPairCalled = true
        throw RateStoreError.badLastCurrencyPairData
    }

    func saveLastCurrencyPair(_ currencyPair: CurrencyPair) async throws {
        saveLastCurrencyPairCalled = true
        throw RateStoreError.failedToSaveLastCurrencyPair
    }
}
