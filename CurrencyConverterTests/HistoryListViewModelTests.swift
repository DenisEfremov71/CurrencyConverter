//
//  HistoryListViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import XCTest
@testable import CurrencyConverter

final class HistoryListViewModelTests: XCTestCase {

    var sut: HistoryListViewModel!
    var currencyManagerMock: CurrencyManagerMock!

    override func setUp() {
        super.setUp()
        currencyManagerMock =  CurrencyManagerMock()
        currencyManagerMock.exchangeRates = CurrencyPair.mockExchangeRates
        sut = HistoryListViewModel(currencyManager: currencyManagerMock)
    }

    override func tearDown() {
        currencyManagerMock = nil
        sut = nil
        super.tearDown()
    }

    func test_whenGetTransactionsCalled_shouldCallMethodOnCurrencyManager() async throws {
        XCTAssertTrue(!currencyManagerMock.loadHistoryCalled)
        try await sut.getTransactions()
        XCTAssertTrue(currencyManagerMock.loadHistoryCalled)
    }

}
