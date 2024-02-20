//
//  Constants.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

struct Constants {

    // Get your own API key at https://freecurrencyapi.com/
    static let apiKey = "fca_live_ucH2yu8WkCkdov18EgCthQB59q9gdnAdctFWfviK"

    struct Urls {
        static let base = "https://api.freecurrencyapi.com/v1/latest?apikey=\(apiKey)"
    }
}
