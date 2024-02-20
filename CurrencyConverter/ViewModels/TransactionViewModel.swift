//
//  TransactionViewModel.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

struct TransactionViewModel {
    let transaction: Transaction

    var title: String {
        "\(transaction.base.rawValue)/\(transaction.quote.rawValue)"
    }

    var dateTime: String {
        "\(transaction.date.formatted(.dateTime))"
    }

    var amount: String {
        "Amount: \(transaction.amount.formatted(.currency(code: transaction.base.rawValue)))"
    }

    var converted: String {
        "Converted: \(transaction.total.formatted(.currency(code: transaction.quote.rawValue)))"
    }
}
