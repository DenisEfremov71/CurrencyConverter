//
//  CurrencyManager.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import Foundation

protocol Manager {
    var exchangeRates: [CurrencyPair] { get }
    var lastCurrencyPair: CurrencyPair { get }
    var history: [Transaction] { get }
    var errorMessage: String { get }
    var total: Double { get }

    func convert(fromCurrency: CurrencyCode, toCurrency: CurrencyCode, for amount: Double)
    func loadLastCurrencyPair(with ratePersistable: RatePersistable) async throws
    func saveLastCurrencyPair(_ base: CurrencyCode, _ quote: CurrencyCode, with ratePersistable: RatePersistable) async throws
    func loadHistory(with historyPersistable: HistoryPersistable) async throws
    func saveHistory(with historyPersistable: HistoryPersistable) async throws
}

class CurrencyManager: Manager, ObservableObject {
    var timer: Timer?

    static let shared = CurrencyManager()

    init() {}

    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }

    @Published var exchangeRates: [CurrencyPair] = []
    @Published var lastCurrencyPair: CurrencyPair = CurrencyPair.placeholder
    @Published var history: [Transaction] = []
    @Published var errorMessage: String = ""
    @Published var total: Double = 0.0

    func startRefreshRatesTimer(with currencyService: CurrencyService, timeInterval: TimeInterval, repeats: Bool = true, completion: (() -> ())? = nil) {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: { [weak self] _ in
            guard let self = self else { return }
            self.fetchAllRates(with: currencyService)
            completion?()
        })
    }

    func getRates(with currencyService: CurrencyService, ratePersistable: RatePersistable) async throws {
        do {
            try await loadRates(with: ratePersistable)
            if exchangeRates.isEmpty {
                fetchAllRates(with: currencyService)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func loadRates(with ratePersistable: RatePersistable) async throws {
        do {
            try await ratePersistable.loadRates()
            DispatchQueue.main.async {
                self.exchangeRates = ratePersistable.rates
            }
        } catch RateStoreError.badURL {
            throw CurrencyManagerError.failedToLoadExchangeRates(RateStoreError.badURL)
        } catch {
            throw error
        }
    }

    private func fetchAllRates(with currencyService: CurrencyService) {
        currencyService.getRates { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let currencyData):
                DispatchQueue.main.async {
                    self.exchangeRates = currencyData.data.map { (key, value) in
                        let quoteCurrency = CurrencyCode(rawValue: key) ?? .usd
                        return CurrencyPair(base: .usd, quote: quoteCurrency, rate: value)
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.errorMessage = CurrencyManagerError.noInternetConnection.localizedDescription
                }
            }
        }
    }

    func convert(fromCurrency: CurrencyCode = .usd, toCurrency: CurrencyCode, for amount: Double) {
        guard !exchangeRates.isEmpty else {
            errorMessage = CurrencyManagerError.noExchangeRatesAvailable.localizedDescription
            return
        }

        let rate = exchangeRates.getCrossRate(fromCurrency, toCurrency)

        guard rate > 0 , amount > 0 else {
            return
        }

        total = rate * amount

        let conversion = Transaction(date: .now, base: fromCurrency, quote: toCurrency, amount: amount, total: total)
        history.append(conversion)
    }

    func saveRates(with ratePersistable: RatePersistable) async throws {
        if exchangeRates.isEmpty { return }
        do {
            try await ratePersistable.saveRates(rates: exchangeRates)
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorMessage = CurrencyManagerError.failedToSaveExchangeRates.localizedDescription +
                "; details: " + error.localizedDescription
            }
        }
    }

    func loadLastCurrencyPair(with ratePersistable: RatePersistable) async throws {
        do {
            try await ratePersistable.loadLastCurrencyPair()
            if let lastCurrencyPair = ratePersistable.lastCurrencyPair {
                DispatchQueue.main.async {
                    self.lastCurrencyPair = lastCurrencyPair
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorMessage = CurrencyManagerError.failedToLoadLastCurrencyPair.localizedDescription +
                "; details: " + error.localizedDescription
            }
        }
    }

    func saveLastCurrencyPair(_ base: CurrencyCode, _ quote: CurrencyCode, with ratePersistable: RatePersistable) async throws {
        let lastCurrencyPair = CurrencyPair(base: base, quote: quote, rate: 1)
        do {
            try await ratePersistable.saveLastCurrencyPair(lastCurrencyPair)
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorMessage = CurrencyManagerError.failedToSaveLastCurrencyPair.localizedDescription +
                "; details: " + error.localizedDescription
            }
        }
    }

    func loadHistory(with historyPersistable: HistoryPersistable) async throws {
        do {
            try await historyPersistable.loadHistory()
            DispatchQueue.main.async {
                self.history = historyPersistable.items
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorMessage = CurrencyManagerError.failedToLoadHistory.localizedDescription +
                "; details: " + error.localizedDescription
            }
        }
    }

    func saveHistory(with historyPersistable: HistoryPersistable) async throws {
        guard !history.isEmpty else { return }
        do {
            try await historyPersistable.saveHistory(history)
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorMessage = CurrencyManagerError.failedToSaveHistory.localizedDescription +
                "; details: " + error.localizedDescription
            }
        }
    }
}

enum CurrencyManagerError: Error, CustomStringConvertible {
    case failedToLoadExchangeRates(RateStoreError)
    case failedToSaveExchangeRates
    case failedToLoadLastCurrencyPair
    case failedToSaveLastCurrencyPair
    case failedToLoadHistory
    case failedToSaveHistory
    case noExchangeRatesAvailable
    case noInternetConnection

    var localizedDescription: String {
        self.description
    }

    var description: String {
        switch self {
        case .failedToLoadExchangeRates(let error):
            return "Failed to load exchange rates; details: \(error.localizedDescription)"
        case .failedToSaveExchangeRates:
            return "Failed to save exchange rates"
        case .failedToLoadLastCurrencyPair:
            return "Failed to load last chosen currency pair"
        case .failedToSaveLastCurrencyPair:
            return "Failed to save last chosen currency pair"
        case .failedToLoadHistory:
            return "Failed to load transaction history"
        case .failedToSaveHistory:
            return "Failed to save transaction history"
        case .noExchangeRatesAvailable:
            return "No exchange rates available"
        case .noInternetConnection:
            return "Failed to fetch exchange rates. Please check your Internet connection."
        }
    }
}
