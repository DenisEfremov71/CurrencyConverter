//
//  Transaction.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-19.
//

import Foundation

struct Transaction: Codable, Identifiable {
    var id: UUID {
        UUID()
    }
    let date: Date
    let base: CurrencyCode
    let quote: CurrencyCode
    let amount: Double
    let total: Double
}

extension Transaction: CustomStringConvertible {
    var description: String {
        date.formatted(.dateTime) + ": \(base.rawValue)/\(quote.rawValue)"
    }
}

extension Transaction {
    static var placeholder: Transaction {
        Transaction(date: .now, base: .usd, quote: .eur, amount: 10, total: 9.28)
    }
}
