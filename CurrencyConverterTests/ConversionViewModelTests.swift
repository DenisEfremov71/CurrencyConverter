//
//  ConversionViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import XCTest
@testable import CurrencyConverter

final class ConversionViewModelTests: XCTestCase {

    var sut: ConversionViewModel!
    var currencyManagerMock: CurrencyManagerMock!

    override func setUp() {
        super.setUp()
        currencyManagerMock =  CurrencyManagerMock()
        currencyManagerMock.exchangeRates = CurrencyPair.mockExchangeRates
        sut = ConversionViewModel(currencyManager: currencyManagerMock)
    }

    override func tearDown() {
        currencyManagerMock = nil
        sut = nil
        super.tearDown()
    }

    func test_whenCalculateRateCalled_shouldCallMethodOnCurrencyManager() {
        XCTAssertTrue(!currencyManagerMock.convertCalled)
        sut.calculateRate(fromCurrency: .usd, toCurrency: .eur, for: 1.0)
        XCTAssertTrue(currencyManagerMock.convertCalled)
    }

    func test_whenLoadLastCurrencyPairCalled_shouldCallMethodOnCurrencyManager() async throws {
        XCTAssertTrue(!currencyManagerMock.loadLastCurrencyPairCalled)
        try await sut.loadLastCurrencyPair()
        XCTAssertTrue(currencyManagerMock.loadLastCurrencyPairCalled)
    }

    func test_whenSaveLastCurrencyPairCalled_shouldCallMethodOnCurrencyManager() async throws {
        XCTAssertTrue(!currencyManagerMock.saveLastCurrencyPairCalled)
        try await sut.saveLastCurrencyPair()
        XCTAssertTrue(currencyManagerMock.saveLastCurrencyPairCalled)
    }

    func test_whenSaveHistoryCalled_shouldCallMethodOnCurrencyManager() async throws {
        XCTAssertTrue(!currencyManagerMock.saveHistoryCalled)
        try await sut.saveHistory()
        XCTAssertTrue(currencyManagerMock.saveHistoryCalled)
    }
}
