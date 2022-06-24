//
//  MyProductsTotalMoneyView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//

import SwiftUI

struct MyProductsMoneyView: View {
    
    @ObservedObject var viewModel: MyProductsMoneyViewModel
    
    var body: some View {

        VStack {

            ZStack() {

                VStack {

                    HStack(alignment: .bottom) {

                        if viewModel.balance.count > 8 {

                            VStack(alignment: .leading, spacing: 8) {

                                Text(viewModel.title)
                                    .font(.textH2SB20282())
                                    .foregroundColor(.mainColorsBlack)

                                Text(viewModel.balance)
                                    .font(.textH2SB20282())
                                    .foregroundColor(.mainColorsBlack)
                            }

                            Spacer()

                        } else {

                            Text(viewModel.title)
                                .font(.textH2SB20282())
                                .foregroundColor(.mainColorsBlack)

                            Spacer()

                            Text(viewModel.balance)
                                .font(.textH2SB20282())
                                .foregroundColor(.mainColorsBlack)
                        }

                        MyProductsMoneyViewButton(viewModel: viewModel.currencyButton)
                    }
                    .padding([.leading, .top], 20)
                    .padding(.bottom, 4)

                    HStack {

                        Spacer()

                        Text(viewModel.subtitle)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)
                            .padding(.trailing)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 16)
        }.background(Color.barsTabbar)
    }
}

extension MyProductsMoneyView {

    struct MyProductsMoneyViewButton: View {

        @ObservedObject var viewModel: MyProductsMoneyViewModel.CurrencyButtonViewModel

        private var foregroundColor: Color {

            if viewModel.isSelected {
                return .mainColorsBlack
            }

            return .mainColorsGrayMedium
        }

        var body: some View {

            Button {

                viewModel.isSelected.toggle()

            } label: {

                ZStack {

                    HStack {

                        Capsule()
                            .foregroundColor(foregroundColor)

                    }.frame(width: 40, height: 24)

                    HStack(spacing: 3) {

                        Text(viewModel.title)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textWhite)

                        viewModel.icon
                            .foregroundColor(.iconWhite)

                    }.padding(.vertical, 4)
                }
            }.padding(.trailing, 19)
        }
    }
}

struct MyProductsTotalMoneyView_Previews: PreviewProvider {
    static var previews: some View {

        Group {

            MyProductsMoneyView(viewModel: .sample1)
                .previewLayout(.sizeThatFits)

            MyProductsMoneyView(viewModel: .sample2)
                .previewLayout(.sizeThatFits)
        }
    }
}
