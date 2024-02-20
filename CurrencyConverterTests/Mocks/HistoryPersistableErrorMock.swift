//
//  HistoryPersistableErrorMock.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation
@testable import CurrencyConverter

class HistoryPersistableErrorMock: HistoryPersistable {
    var items: [Transaction] = []

    var loadHistoryCalled = false
    var saveHistoryCalled = false

    func loadHistory() async throws {
        loadHistoryCalled = true
        throw HistoryStoreError.badURL
    }

    func saveHistory(_ items: [Transaction]) async throws {
        saveHistoryCalled = true
        throw HistoryStoreError.failedToEncode
    }
}
