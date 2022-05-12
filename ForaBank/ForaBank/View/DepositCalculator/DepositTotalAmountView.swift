//
//  DepositTotalAmountView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import SwiftUI

struct DepositTotalAmountView: View {

    @ObservedObject var viewModel: DepositTotalAmountViewModel

    var body: some View {

        ZStack {

            Color(hex: "#292929")
                .opacity(0.4)
                .cornerRadius(12)
                .frame(height: 128)

            VStack(alignment: .leading, spacing: 8) {

                HStack {

                    VStack(alignment: .leading, spacing: 8) {

                        Text(viewModel.yourIncomeTitle)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)

                        Text(viewModel.yourIncomeCurrency)
                            .foregroundColor(.mainColorsWhite)
                            .font(.textH4M16240())
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {

                        Text(viewModel.totalAmountTitle)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)

                        Text(viewModel.totalAmountCurrency)
                            .foregroundColor(.mainColorsWhite)
                            .font(.textH4M16240())

                    }.frame(width: 150, alignment: .leading)

                    Spacer()
                        .fixedSize()
                }

                Text(viewModel.description)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
                    .padding(.top, 8)

            }.padding(20)
        }
    }
}

struct DepositTotalAmountView_Previews: PreviewProvider {
    static var previews: some View {
        DepositTotalAmountView(viewModel: .sample)
            .background(Color.mainColorsBlack)
            .previewLayout(.sizeThatFits)
    }
}
