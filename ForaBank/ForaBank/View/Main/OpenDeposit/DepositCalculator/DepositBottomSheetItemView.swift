//
//  DepositBottomSheetItemView.swift
//  Vortex
//
//  Created by Pavel Samsonov on 03.05.2022.
//

import SwiftUI

struct DepositBottomSheetItemView: View {

    let viewModel: DepositBottomSheetItemViewModel

    var body: some View {

        HStack {

            VStack(alignment: .leading, spacing: 8) {

                Text(viewModel.termName)
                    .font(.textH4M16240())
                Text("\(viewModel.term) дней")
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
            }

            Spacer()
            
            if viewModel.isOnCapitalization {
                
                VStack(alignment: .trailing, spacing: 8) {

                    Text("до \(viewModel.ratePercent)")
                        .font(.textH4M16240())
                        .accessibilityIdentifier("DepositBottomSheetRate")
                    Text(viewModel.capitalizationTitle)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                }
            }
        }
    }
}

struct DepositBottomSheetItemView_Previews: PreviewProvider {
    static var previews: some View {
        DepositBottomSheetItemView(
            viewModel: .init(
                term: 365,
                rate: 8.25,
                termName: "1 год"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
