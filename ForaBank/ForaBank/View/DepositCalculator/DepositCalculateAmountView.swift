//
//  DepositCalculateAmountView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import SwiftUI

struct DepositCalculateAmountView: View {

    @ObservedObject var viewModel: DepositCalculateAmountViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {

                VStack(alignment: .leading, spacing: 8) {

                    Text(viewModel.depositTerm)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)

                    HStack {

                        Text("\(viewModel.depositValue) дней")
                            .foregroundColor(.mainColorsWhite)
                            .font(.textH4M16240())

                        Button {

                            viewModel.isShowBottomSheet.toggle()

                        } label: {

                            Image(viewModel.depositTermNamed)
                                .renderingMode(.original)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {

                    Text(viewModel.interestRate)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)

                    Text(viewModel.percentFormat(viewModel.interestRateValue))
                        .foregroundColor(.mainColorsWhite)
                        .font(.textH4M16240())
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {

                Text(viewModel.depositAmount)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)

                HStack {

                    TextField("", value: $viewModel.value, formatter: viewModel.numberFormatter)
                        .foregroundColor(.mainColorsWhite)
                        .font(.textH1SB24322())
                        .keyboardType(.decimalPad)
                        .fixedSize()

                    Button {
                        // action
                    } label: {

                        Image(viewModel.depositAmountNamed)
                            .renderingMode(.original)
                    }
                }
            }
            .padding([.top, .bottom], 8)

            DepositSliderViewComponent(value: $viewModel.value, bounds: viewModel.bounds)
                .padding(.bottom, 12)

        }.padding([.leading, .trailing], 20)
    }
}

struct DepositCalculateAmountView_Previews: PreviewProvider {
    static var previews: some View {

        DepositCalculateAmountView(viewModel: .sample1)
            .background(Color.mainColorsBlack)
            .previewLayout(.sizeThatFits)
    }
}
