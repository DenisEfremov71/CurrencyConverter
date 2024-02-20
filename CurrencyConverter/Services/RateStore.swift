//
//  RateStore.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

protocol RatePersistable {
    var rates: [CurrencyPair] { get }
    var lastCurrencyPair: CurrencyPair? { get }

    func loadRates() async throws
    func saveRates(rates: [CurrencyPair]) async throws
    func loadLastCurrencyPair() async throws
    func saveLastCurrencyPair(_ currencyPair: CurrencyPair) async throws
}

final class RateStore: RatePersistable {
    var rates: [CurrencyPair] = []
    var lastCurrencyPair: CurrencyPair?

    private static func fileURL(filename: String) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent(filename)
    }

    func loadRates() async throws {
        let task = Task<[CurrencyPair], Error> {
            guard let fileURL = try? Self.fileURL(filename: "rates.data") else {
                throw RateStoreError.badURL
            }

            guard let data = try? Data(contentsOf: fileURL) else {
                //throw RateStoreError.badRatesData
                return []
            }

            guard let rates = try? JSONDecoder().decode([CurrencyPair].self, from: data) else {
                throw RateStoreError.failedToDecodeRates
            }

            return rates
        }

        let result = await task.result

        do {
            let rates = try result.get()
            self.rates = rates
        } catch RateStoreError.badURL {
            throw RateStoreError.badURL
        } catch RateStoreError.badRatesData {
            throw RateStoreError.badRatesData
        } catch RateStoreError.failedToDecodeRates {
            throw RateStoreError.failedToDecodeRates
        } catch {
            throw RateStoreError.unknownError
        }
    }

    func saveRates(rates: [CurrencyPair]) async throws {
        let task = Task<Bool, Error> {
            guard let data = try? JSONEncoder().encode(rates) else {
                throw RateStoreError.failedToEncodeRates
            }

            guard let fileURL = try? Self.fileURL(filename: "rates.data") else {
                throw RateStoreError.badURL
            }

            do {
                try data.write(to: fileURL)
                return true
            } catch {
                throw RateStoreError.failedToSaveRates
            }
        }

        let result = await task.result

        do {
            let _ = try result.get()
        } catch RateStoreError.failedToEncodeRates {
            throw RateStoreError.failedToEncodeRates
        } catch RateStoreError.badURL {
            throw RateStoreError.badURL
        } catch RateStoreError.failedToSaveRates {
            throw RateStoreError.failedToSaveRates
        } catch {
            throw RateStoreError.unknownError
        }
    }

    func loadLastCurrencyPair() async throws {
        let task = Task<CurrencyPair, Error> {
            guard let fileURL = try? Self.fileURL(filename: "last.currency.pair.data") else {
                throw RateStoreError.badURL
            }

            guard let data = try? Data(contentsOf: fileURL) else {
                return CurrencyPair.placeholder
            }

            guard let currencyPair = try? JSONDecoder().decode(CurrencyPair.self, from: data) else {
                throw RateStoreError.failedToDecodeLastCurrencyPair
            }

            return currencyPair
        }

        let result = await task.result

        do {
            let lastCurrencyPair = try result.get()
            self.lastCurrencyPair = lastCurrencyPair
        } catch RateStoreError.badURL {
            throw RateStoreError.badURL
        } catch RateStoreError.badLastCurrencyPairData {
            throw RateStoreError.badLastCurrencyPairData
        } catch RateStoreError.failedToDecodeLastCurrencyPair {
            throw RateStoreError.failedToDecodeLastCurrencyPair
        } catch {
            throw RateStoreError.unknownError
        }

    }

    func saveLastCurrencyPair(_ currencyPair: CurrencyPair) async throws {
        let task = Task<Bool, Error> {
            guard let data = try? JSONEncoder().encode(currencyPair) else {
                throw RateStoreError.failedToEncodeLastCurrencyPair
            }

            guard let fileURL = try? Self.fileURL(filename: "last.currency.pair.data") else {
                throw RateStoreError.badURL
            }
            do {
                try data.write(to: fileURL)
                return true
            } catch {
                throw RateStoreError.failedToSaveLastCurrencyPair
            }
        }

        let result = await task.result

        do {
            let _ = try result.get()
        } catch RateStoreError.failedToEncodeLastCurrencyPair {
            throw RateStoreError.failedToEncodeLastCurrencyPair
        } catch RateStoreError.badURL {
            throw RateStoreError.badURL
        } catch RateStoreError.failedToSaveLastCurrencyPair {
            throw RateStoreError.failedToSaveLastCurrencyPair
        } catch {
            throw RateStoreError.unknownError
        }
    }
}

enum RateStoreError: Error, CustomStringConvertible {
    case badURL
    case badRatesData
    case badLastCurrencyPairData
    case failedToSaveRates
    case failedToEncodeRates
    case failedToDecodeRates
    case failedToSaveLastCurrencyPair
    case failedToEncodeLastCurrencyPair
    case failedToDecodeLastCurrencyPair
    case unknownError

    var localizedDescription: String {
        self.description
    }

    var description: String {
        switch self {
        case .badURL:
            return "Bad URL for Rates Store"
        case .badRatesData:
            return "Rates data corrupted"
        case .badLastCurrencyPairData:
            return "Last currency pair data corrupted"
        case .failedToSaveRates:
            return "Failed to save rates"
        case .failedToEncodeRates:
            return "Failed to encode rates"
        case .failedToDecodeRates:
            return "Failed to decode rates"
        case .failedToSaveLastCurrencyPair:
            return "Failed to save last chosen currency pair"
        case .failedToEncodeLastCurrencyPair:
            return "Failed to encode last chosen currency pair"
        case .failedToDecodeLastCurrencyPair:
            return "Failed to decode last chosen currency pair"
        case .unknownError:
            return "Unknown error"
        }
    }
}
