//
//  MyProductsСurrencyMenuView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 20.04.2022.
//

import SwiftUI

struct MyProductsCurrencyMenuView: View {

    @ObservedObject var viewModel: MyProductsСurrencyMenuViewModel

    var body: some View {

        VStack(spacing: 16) {

            ForEach(viewModel.items) { item in

                Button {

                    viewModel.action.send(MyProductsСurrencyMenuAction(
                        moneySign: item.moneySign,
                        subtitle: item.subtitle)
                    )

                } label: {

                    HStack(alignment: .top) {
                        item.icon
                            .renderingMode(.original)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.mainColorsBlackMedium)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .foregroundColor(.mainColorsBlack)
                                .font(.textBodyMM14200())

                            HStack(spacing: 2) {
                                Text(item.moneySign)
                                    .foregroundColor(.mainColorsGray)
                                    .font(.textBodySM12160())

                                Text(item.subtitle)
                                    .foregroundColor(.mainColorsGray)
                                    .font(.textBodySM12160())
                            }
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .clipped()
        .shadow(color: .mainColorsGrayMedium, radius: 4, x: 0, y: 4)
    }
}

struct MyProductsCurrencyMenuView_Previews: PreviewProvider {
    static var previews: some View {
        
        MyProductsCurrencyMenuView(viewModel: .init(items: [
            .init(icon: .init("Dollar"),
                  moneySign: "$",
                  title: "Доллар США",
                  subtitle: "936 107"),
            .init(icon: .init("Swiss Franc"),
                  moneySign: "₣",
                  title: "Швейцарский франк",
                  subtitle: "848 207"),
            .init(icon: .init("Euro"),
                  moneySign: "$",
                  title: "ЕВРО",
                  subtitle: "787 041"),
            .init(icon: .init("Pound Sterling"),
                  moneySign: "₣",
                  title: "Фунт стерлингов",
                  subtitle: "669 891")
        ])).previewLayout(.fixed(width: 239, height: 200))
    }
}
