//
//  URL+Extensions.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

extension URL {
    static var getCurrencyRatesURL: URL? {
        let baseCurrency: CurrencyCode = .usd
        let urlString = Constants.Urls.base + baseCurrency.quoteCurrenciesQuery() + baseCurrency.baseCurrencyQuery()
        return URL(string: urlString)
    }
}
