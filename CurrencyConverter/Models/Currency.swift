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

extension CurrencyPair: Equatable {
    static func == (lhs: CurrencyPair, rhs: CurrencyPair) -> Bool {
        lhs.base.rawValue == rhs.base.rawValue &&
        lhs.quote.rawValue == rhs.quote.rawValue &&
        lhs.rate == rhs.rate
    }
}

extension CurrencyPair {
    static var placeholder: CurrencyPair {
        CurrencyPair(base: .usd, quote: .eur, rate: 0.9274001064)
    }

    static var placeholderTwo: CurrencyPair {
        CurrencyPair(base: .usd, quote: .gbp, rate: 0.7931301518)
    }

    static var mockExchangeRates: [CurrencyPair] = [
        CurrencyPair(base: .usd, quote: .chf, rate: 0.8808601544),
        CurrencyPair(base: .usd, quote: .cny, rate: 7.1871413477),
        CurrencyPair(base: .usd, quote: .eur, rate: 0.9274001064),
        CurrencyPair(base: .usd, quote: .gbp, rate: 0.7931301518),
        CurrencyPair(base: .usd, quote: .rub, rate: 91.8593467603),
        CurrencyPair(base: .usd, quote: .usd, rate: 1)
    ]
}
