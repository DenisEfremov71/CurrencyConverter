//
//  Array+Extensions.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

extension Array where Element == CurrencyPair {
    func getRate(for currency: CurrencyCode) -> Double {
        guard !self.isEmpty else { return 0 }
        return self.filter { $0.quote == currency }.first?.rate ?? 0
    }

    func getCrossRate(_ base: CurrencyCode, _ quote: CurrencyCode) -> Double {
        let reversedBase = 1 / self.getRate(for: base)
        let quoteRate = self.getRate(for: quote)
        return reversedBase * quoteRate
    }
}
