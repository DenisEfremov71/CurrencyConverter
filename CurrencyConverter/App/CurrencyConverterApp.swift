//
//  CurrencyConverterApp.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-19.
//

import SwiftUI

@main
struct CurrencyConverterTestApp: App {

    @StateObject var currencyManager = CurrencyManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(currencyManager)
                .task {
                    do {
                        currencyManager.startRefreshRatesTimer(with: FreeCurrencyService(), timeInterval: 300)
                        try await currencyManager.getRates(with: FreeCurrencyService(), ratePersistable: RateStore())
                        try await currencyManager.loadHistory(with: HistoryStore())
                    } catch {
                        currencyManager.errorMessage = CurrencyManagerError.failedToLoadExchangeRates(.unknownError).localizedDescription
                    }
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .background || phase == .inactive {
                        if !currencyManager.exchangeRates.isEmpty {
                            Task {
                                do {
                                    try await currencyManager.saveRates(with: RateStore())
                                } catch {
                                    currencyManager.errorMessage = CurrencyManagerError.failedToSaveExchangeRates.localizedDescription
                                }
                            }
                        }
                    }
                }
        }
    }
}
