//
//  FreeCurrencyServiceTests.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import XCTest
@testable import CurrencyConverter

final class FreeCurrencyServiceTests: XCTestCase {

    var sut: FreeCurrencyService!
    var url: URL!
    var mockSession: MockURLSession!


    override func setUp() {
        super.setUp()
        url = URL.getCurrencyRatesURL!
        mockSession = MockURLSession()
        sut = FreeCurrencyService(session: mockSession)
    }

    override func tearDown() {
        url = nil
        mockSession = nil
        sut = nil
        super.tearDown()
    }

    func whenGetRates(data: Data? = nil, statusCode: Int = 200, error: Error? = nil) ->
        (calledCompletion: Bool, receivedCurrencyData: CurrencyData?, receivedError: NetworkError?) {

        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)

        var calledCompletion = false
        var receivedCurrencyData: CurrencyData? = nil
        var receivedError: NetworkError? = nil

        let mockTask = sut.getRates() { result in
            switch result {
            case .success(let currencyData):
                receivedCurrencyData = currencyData
            case .failure(let error):
                receivedError = error as? NetworkError
            }
            calledCompletion = true
        } as! MockURLSessionTask

        mockTask.completionHandler(data, response, error)
        return (calledCompletion, receivedCurrencyData, receivedError)
    }

    // MARK: - Happy Path

    func test_init_setsURL() {
        XCTAssertEqual(sut.url, url)
    }

    func test_init_setsSession() {
        XCTAssertTrue(sut.session === mockSession)
    }

    func test_getRates_callsExpectedURL() {
        let mockTask = sut.getRates() { _ in } as! MockURLSessionTask
        XCTAssertEqual(mockTask.url, url)
    }

    func test_getRates_callsResumeOnTask() {
        let mockTask = sut.getRates { _ in } as! MockURLSessionTask
        XCTAssertTrue(mockTask.calledResume)
    }

    // MARK: - Error Handling

    func test_getRates_givenResponseStatusCode500_callsCompletion() {
        let result = whenGetRates(statusCode: 500)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.receivedCurrencyData)
        XCTAssertNotNil(result.receivedError)
    }

    func test_getRates_givenError_callsCompletionWithError() throws {
        let expectedError = NetworkError.invalidResponse
        let result = whenGetRates(error: expectedError)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.receivedCurrencyData)
        XCTAssertNotNil(result.receivedError)
        let actualError = result.receivedError
        XCTAssertEqual(actualError, expectedError)
    }

    // MARK: - Deserializing

    func test_getRates_givenValidJSON_callsCompletionWithRates() throws {
        let data = try Data.fromJSON(fileName: "GET_rates_response")
        let result = whenGetRates(data: data)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.receivedCurrencyData)
        XCTAssertNil(result.receivedError)
    }

    func test_getDogs_givenInvalidJSON_callsCompletionWithError() throws {
        let data = try Data.fromJSON(fileName: "GET_rates_missing_key_response")
        let expectedError = NetworkError.failedToDecodeData
        let result = whenGetRates(data: data)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.receivedCurrencyData)
        XCTAssertNotNil(result.receivedError)
        XCTAssertEqual(result.receivedError, expectedError)
    }


}
