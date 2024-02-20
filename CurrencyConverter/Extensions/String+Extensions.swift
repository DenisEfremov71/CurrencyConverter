//
//  String+Extensions.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
