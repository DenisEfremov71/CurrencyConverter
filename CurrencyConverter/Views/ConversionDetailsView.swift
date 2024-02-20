//
//  ConversionDetailsView.swift
//  CurrencyConverter
//
//  Created by Denis Efremov on 2024-02-20.
//

import SwiftUI

struct ConversionDetailsView: View {
    let transactionVM: TransactionViewModel

    var body: some View {
        Form {
            Section(header: Text("Date/Time")) {
                Text("\(transactionVM.dateTime)")
                    .font(.title)
            }

            Section(header: Text("Conversion")) {
                Text("\(transactionVM.amount)")
                    .font(.title3)

                Text("\(transactionVM.converted)")
                    .font(.title3)
            }
        }
        .navigationTitle(transactionVM.title)
    }
}

#Preview {
    ConversionDetailsView(transactionVM: TransactionViewModel(transaction: Transaction.placeholder))
}
