//
//  ConvertView.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import SwiftUI

struct ConvertView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @StateObject var viewModel = ConvertViewModel()
    @State private var amount: String = ""
    @State private var showErrorAlert: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationView {
            Group {
                Spacer()

                Form {
                    Section(header: Text("Currency Pair")) {
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .focused($isFocused)

                        Picker(selection: $viewModel.fromCurrency, label: Text("From")) {
                            ForEach(CurrencyCode.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .onChange(of: viewModel.fromCurrency, perform: { _ in
                            viewModel.total = 0
                        })

                        Picker(selection: $viewModel.toCurrency, label: Text("To")) {
                            ForEach(CurrencyCode.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .onChange(of: viewModel.toCurrency, perform: { _ in
                            viewModel.total = 0
                        })
                    }

                    Section(header: Text("")) {
                        Button(action: {
                            viewModel.calculateRate(
                                fromCurrency: viewModel.fromCurrency,
                                toCurrency: viewModel.toCurrency,
                                for: Double(amount) ?? 0
                            )
                            isFocused = false

                            Task {
                                try await viewModel.saveHistory()
                            }

                        }, label: {
                            Text("Convert")
                        })
                        .disabled(!isFormValid)
                    }

                    Section(header: Text("Total")) {
                        Text("\(viewModel.total.formatted(.currency(code: viewModel.toCurrency.rawValue)))")
                    }
                }

                Spacer()
            }
            .navigationBarBackButtonHidden()
            .navigationTitle("Currency Converter")
        }
        .task {
            do {
                try await viewModel.loadLastCurrencyPair()
            } catch {
                // TODO: - Remove print
                print(error.localizedDescription)
            }
        }
        .onDisappear {
            Task {
                do {
                    try await viewModel.saveLastCurrencyPair()
                } catch {
                    // TODO: - Remove print
                    print(error.localizedDescription)
                }
            }
        }
        .onReceive(currencyManager.$errorMessage, perform: { _ in
            if !currencyManager.errorMessage.isEmpty {
                showErrorAlert = true
            }
        })
        .alert("Error: \(currencyManager.errorMessage)", isPresented: $showErrorAlert) {
            VStack {
                Button("Close", role: .cancel) {}
            }
        }
    }

    private var isFormValid: Bool {
        !amount.isEmptyOrWhiteSpace && Double(amount) != nil
    }
}

#Preview {
    ConvertView()
        .environmentObject(CurrencyManager.shared)
}
