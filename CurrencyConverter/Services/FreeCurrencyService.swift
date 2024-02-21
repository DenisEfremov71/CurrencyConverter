//
//  FreeCurrencyService.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

final class FreeCurrencyService: CurrencyService {
    let url: URL?
    let session: URLSessionProtocol

    init(url: URL? = URL.getCurrencyRatesURL, session: URLSessionProtocol = URLSession.shared) {
        self.url = url
        self.session = session
    }

    func getRates(completion: @escaping (Result<CurrencyData, Error>) -> Void) -> URLSessionTaskProtocol? {
        guard let url = url else {
            completion(.failure(NetworkError.invalidUrl))
            return nil
        }

        let task = session.makeDataTask(with: url) { data, response, error in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.failedToGetData))
                return
            }

            guard let currencyData = try? JSONDecoder().decode(CurrencyData.self, from: data) else {
                completion(.failure(NetworkError.failedToDecodeData))
                return
            }

            completion(.success(currencyData))
        }

        task.resume()

        return task
    }
}
