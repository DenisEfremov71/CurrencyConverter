//
//  CurrencyManagerTests.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import XCTest
@testable import CurrencyConverter

final class CurrencyManagerTests: XCTestCase {

    var sut: CurrencyManager!

    override func setUp() {
        super.setUp()
        sut = CurrencyManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Happy Path

    func test_whenInitialized_exchangeRatesEmpty() {
        XCTAssertTrue(sut.exchangeRates.isEmpty)
    }

//    func test_whenStartTimer_shouldFetchAllRates() {
//        let exp = expectation(description: "RefreshRatesTimer")
//        XCTAssertTrue(sut.exchangeRates.isEmpty)
//        sut.startRefreshRatesTimer(with: CurrencyServiceMock(), timeInterval: 1, repeats: false) {
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 1.5)
//        XCTAssertTrue(!sut.exchangeRates.isEmpty)
//    }

    func test_whenGetRatesCalled_servicesShouldBeCalled() async throws {
        let ratePersistableMock = RatePersistableMock()
        let currencyServiceMock = CurrencyServiceMock()
        XCTAssertTrue(!ratePersistableMock.loadRatesCalled)
        XCTAssertTrue(!currencyServiceMock.getRatesCalled)
        try await sut.getRates(with: currencyServiceMock, ratePersistable: ratePersistableMock)
        XCTAssertTrue(ratePersistableMock.loadRatesCalled)
        XCTAssertTrue(currencyServiceMock.getRatesCalled)
    }

    func test_whenGetRatesCalled_andRatesLoaded_shouldHaveExchangeRates() async throws {
        let ratePersistableMock = RatePersistableMock()
        XCTAssertTrue(ratePersistableMock.rates.isEmpty)
        try await sut.getRates(with: CurrencyServiceMock(), ratePersistable: ratePersistableMock)
        XCTAssertTrue(!ratePersistableMock.rates.isEmpty)
    }

    func test_whenSaveRatesCalled_shouldCallRatePersistableMethod() async throws {
        let ratePersistableMock = RatePersistableMock()
        XCTAssertTrue(!ratePersistableMock.saveRatesCalled)
        sut.exchangeRates = CurrencyPair.mockExchangeRates
        try await sut.saveRates(with: ratePersistableMock)
        XCTAssertTrue(ratePersistableMock.saveRatesCalled)
    }

    func test_whenConvertCurrency_shouldGetCorrectResult() {
        let usdToChfConversionResult = 0.8808601544
        sut.exchangeRates = CurrencyPair.mockExchangeRates
        sut.convert(fromCurrency: .usd, toCurrency: .chf, for: 1)
        XCTAssertEqual(sut.total, usdToChfConversionResult)
    }

    func test_whenLoadLastCurrencyPair_itShouldBeLoaded() async throws {
        let ratePersistableMock = RatePersistableMock()
        XCTAssertTrue(!ratePersistableMock.loadLastCurrencyPairCalled)
        try await sut.loadLastCurrencyPair(with: ratePersistableMock)
        XCTAssertTrue(ratePersistableMock.loadLastCurrencyPairCalled)
        XCTAssertEqual(sut.lastCurrencyPair, CurrencyPair.placeholder)
    }

    func test_whenSaveLastCurrencyPair_shouldCallRatePersistableMethod() async throws {
        let ratePersistableMock = RatePersistableMock()
        XCTAssertTrue(!ratePersistableMock.saveLastCurrencyPairCalled)
        try await sut.saveLastCurrencyPair(.usd, .eur, with: ratePersistableMock)
        XCTAssertTrue(ratePersistableMock.saveLastCurrencyPairCalled)
    }

    func test_whenLoadHistoryCalled_shouldCallHistoryPersistableMethod() async throws {
        let historyPersistableMock = HistoryPersistableMock()
        XCTAssertTrue(!historyPersistableMock.loadHistoryCalled)
        try await sut.loadHistory(with: historyPersistableMock)
        XCTAssertTrue(historyPersistableMock.loadHistoryCalled)
    }

    func test_whenSaveHistoryCalled_shouldCallHistoryPersistableMethod() async throws {
        let historyPersistableMock = HistoryPersistableMock()
        XCTAssertTrue(!historyPersistableMock.saveHistoryCalled)
        sut.history = [Transaction.placeholder]
        try await sut.saveHistory(with: historyPersistableMock)
        XCTAssertTrue(historyPersistableMock.saveHistoryCalled)
    }

    // MARK: - Error Handling

    @MainActor
    func test_whenGetRatesCalled_andRatePersistableFails_shouldSetErrorMessage() async throws {
        let error = "The operation couldn’t be completed. (CurrencyConverter.CurrencyManagerError error 0.)"
        let ratePersistableErrorMock = RatePersistableErrorMock()
        XCTAssertTrue(!ratePersistableErrorMock.loadRatesCalled)
        sut.errorMessage = ""
        try await sut.getRates(with: CurrencyServiceMock(), ratePersistable: ratePersistableErrorMock)
        XCTAssertTrue(ratePersistableErrorMock.loadRatesCalled)
        XCTAssertEqual(sut.errorMessage, error)
    }

    @MainActor
    func test_whenSaveRatesCalled_andRatePersistableFails_shouldSetErrorMessage() async throws {
        let error = "Failed to save exchange rates; details: The operation couldn’t be completed. (CurrencyConverter.RateStoreError error 4.)"
        let ratePersistableErrorMock = RatePersistableErrorMock()
        XCTAssertTrue(!ratePersistableErrorMock.saveRatesCalled)
        sut.errorMessage = ""
        sut.exchangeRates = CurrencyPair.mockExchangeRates
        try await sut.saveRates(with: ratePersistableErrorMock)
        XCTAssertTrue(ratePersistableErrorMock.saveRatesCalled)
        XCTAssertEqual(sut.errorMessage, error)
    }

    @MainActor
    func test_whenLoadLastCurrencyPairCalled_andRatePersistableFails_shouldSetErrorMessage() async throws {
        let error = "Failed to load last chosen currency pair; details: The operation couldn’t be completed. (CurrencyConverter.RateStoreError error 2.)"
        let ratePersistableErrorMock = RatePersistableErrorMock()
        XCTAssertTrue(!ratePersistableErrorMock.loadLastCurrencyPairCalled)
        sut.errorMessage = ""
        try await sut.loadLastCurrencyPair(with: ratePersistableErrorMock)
        XCTAssertTrue(ratePersistableErrorMock.loadLastCurrencyPairCalled)
        XCTAssertEqual(sut.errorMessage, error)
    }

    @MainActor
    func test_whenSaveLastCurrencyPairCalled_andRatePersistableFails_shouldSetErrorMessage() async throws {
        let error = "Failed to save last chosen currency pair; details: The operation couldn’t be completed. (CurrencyConverter.RateStoreError error 6.)"
        let ratePersistableErrorMock = RatePersistableErrorMock()
        XCTAssertTrue(!ratePersistableErrorMock.saveLastCurrencyPairCalled)
        sut.errorMessage = ""
        try await sut.saveLastCurrencyPair(.usd, .eur, with: ratePersistableErrorMock)
        XCTAssertTrue(ratePersistableErrorMock.saveLastCurrencyPairCalled)
        XCTAssertEqual(sut.errorMessage, error)
    }

    @MainActor
    func test_whenLoadHistoryCalled_andHistoryPersistableFails_shouldSetErrorMessage() async throws {
        let error = "Failed to load transaction history; details: The operation couldn’t be completed. (CurrencyConverter.HistoryStoreError error 0.)"
        let historyPersistableErrorMock = HistoryPersistableErrorMock()
        XCTAssertTrue(!historyPersistableErrorMock.loadHistoryCalled)
        sut.errorMessage = ""
        try await sut.loadHistory(with: historyPersistableErrorMock)
        XCTAssertTrue(historyPersistableErrorMock.loadHistoryCalled)
        XCTAssertEqual(sut.errorMessage, error)
    }

    @MainActor
    func test_whenSaveHistoryCalled_andHistoryPersistableFails_shouldSetErrorMessage() async throws {
        let error = "Failed to save transaction history; details: The operation couldn’t be completed. (CurrencyConverter.HistoryStoreError error 2.)"
        let historyPersistableErrorMock = HistoryPersistableErrorMock()
        XCTAssertTrue(!historyPersistableErrorMock.saveHistoryCalled)
        sut.errorMessage = ""
        sut.history = [Transaction.placeholder]
        try await sut.saveHistory(with: historyPersistableErrorMock)
        XCTAssertTrue(historyPersistableErrorMock.saveHistoryCalled)
        XCTAssertEqual(sut.errorMessage, error)
    }
}
