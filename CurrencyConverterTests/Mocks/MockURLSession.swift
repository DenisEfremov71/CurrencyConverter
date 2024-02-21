//
//  MockURLSession.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation
@testable import CurrencyConverter

class MockURLSession: URLSessionProtocol {
    func makeDataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTaskProtocol {
        return MockURLSessionTask(completionHandler: completionHandler, url: url)
    }
}

class MockURLSessionTask: URLSessionTaskProtocol {
    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var url: URL
    var calledResume = false

    init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void, url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }

    func resume() {
        calledResume = true
    }
}

