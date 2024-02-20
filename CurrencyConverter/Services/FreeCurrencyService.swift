//
//  FreeCurrencyService.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

final class FreeCurrencyService: CurrencyService {
    func getRates(completion: @escaping (Result<CurrencyData, Error>) -> Void) {
        let baseCurrency: CurrencyCode = .usd
        let urlString = Constants.Urls.base + baseCurrency.quoteCurrenciesQuery() + baseCurrency.baseCurrencyQuery()

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.failedToGetData))
                return
            }

            guard let currencyData = try? JSONDecoder().decode(CurrencyData.self, from: data) else {
                completion(.failure(NetworkError.failedToDecodeData))
                return
            }

            completion(.success(currencyData))

        }.resume()
    }
}
