//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

protocol CurrencyService {
    var url: URL? { get }
    var session: URLSessionProtocol { get }
    func getRates(completion: @escaping (Result<CurrencyData, Error>) -> Void) -> URLSessionTaskProtocol?
}

enum NetworkError: Error {
    case invalidUrl
    case invalidResponse
    case failedToGetData
    case failedToDecodeData
}
