//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

protocol CurrencyService {
    func getRates(completion: @escaping (Result<CurrencyData, Error>) -> Void)
}

enum NetworkError: Error {
    case invalidUrl
    case failedToGetData
    case failedToDecodeData
}
