//
//  CurrencyServiceMock.swift
//  CurrencyConverterTests
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation
@testable import CurrencyConverter

class CurrencyServiceMock: CurrencyService {
    var url: URL? = nil
    var session: URLSessionProtocol = URLSession.shared
    
    var getRatesCalled = false

    func getRates(completion: @escaping (Result<CurrencyData, Error>) -> Void) -> URLSessionTaskProtocol? {
        let currencyData: CurrencyData = CurrencyData(data: [
            "CHF": 0.8808601544,
            "CNY": 7.1871413477,
            "EUR": 0.9274001064,
            "GBP": 0.7931301518,
            "RUB": 91.8593467603
        ])
        completion(.success(currencyData))
        getRatesCalled = true
        return nil
    }
}
