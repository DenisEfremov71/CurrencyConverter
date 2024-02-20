//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-19.
//

import Foundation

enum CurrencyCode: String, CaseIterable, Identifiable, Codable, Equatable {
    case chf = "CHF"
    case cny = "CNY"
    case eur = "EUR"
    case gbp = "GBP"
    case rub = "RUB"
    case usd = "USD"

    private enum CodingKeys: String, CodingKey {
        case chf = "CHF"
        case cny = "CNY"
        case eur = "EUR"
        case gbp = "GBP"
        case rub = "RUB"
        case usd = "USD"
    }

    var id: String {
        self.rawValue
    }

    func excludeCurrency() -> [CurrencyCode] {
        let base: Set<CurrencyCode> = [self]
        return Array(Set(CurrencyCode.allCases).subtracting(base))
    }

    func quoteCurrenciesQuery() -> String {
        "&currencies=" + CurrencyCode.allCases.map { $0.rawValue }.joined(separator: "%2C")
    }

    func baseCurrencyQuery() -> String {
        "&base_currency=\(self.rawValue)"
    }
}

struct CurrencyPair: Codable {
    let base: CurrencyCode
    let quote: CurrencyCode
    let rate: Double
}

extension CurrencyPair {
    static var placeholder: CurrencyPair {
        CurrencyPair(base: .usd, quote: .eur, rate: 0.927790165)
    }
}
