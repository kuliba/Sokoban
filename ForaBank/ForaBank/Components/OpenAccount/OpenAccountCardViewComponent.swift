//
//  OpenAccountCardViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.06.2022.
//

import SwiftUI

// MARK: - ViewModel

extension OpenAccountCardView {

    class ViewModel: ObservableObject {

        @Published var numberCard: String
        @Published var icon: Image?
        
        let balance: Double
        let currrentAccountTitle: String
        let currencyBalance: String
        let currencySymbol: String

        var numberCardLast: String {
            
            if numberCard.isEmpty == false {
                return "\(numberCard.suffix(4))"
            } else {
                return ""
            }
        }

        init(balance: Double = 0,
             numberCard: String = "",
             currrentAccountTitle: String = "Текущий счет",
             currencySymbol: String,
             icon: Image?) {

            self.balance = balance
            self.numberCard = numberCard
            self.currrentAccountTitle = currrentAccountTitle
            self.currencySymbol = currencySymbol
            self.icon = icon

            currencyBalance = "\(balance.currencyDepositFormatter(symbol: currencySymbol))"
        }
    }
}

// MARK: - View

struct OpenAccountCardView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        ZStack {

            if let icon = viewModel.icon {
                
                icon
                    .resizable()
                    .frame(width: 112, height: 72)
                
            } else {
                
                Color.cardAccount
                    .cornerRadius(8)
                    .frame(width: 112, height: 72)
            }

            HStack {

                VStack(alignment: .leading, spacing: 5) {

                    HStack(spacing: 3) {

                        Text(viewModel.numberCardLast)
                            .font(.textBodyXSR11140())
                            .foregroundColor(.mainColorsWhite)
                        
                    }.padding(.leading, 29)

                    VStack(alignment: .leading, spacing: 3) {

                        Text(viewModel.currrentAccountTitle)
                            .font(.textBodyXSR11140())
                            .foregroundColor(.mainColorsGrayMedium)

                        Text(viewModel.currencyBalance)
                            .font(.textBodyXSSB11140())
                            .foregroundColor(.mainColorsWhite)

                    }.padding(.top, 2)

                }.padding([.leading], 8)

                Spacer()
            }
            
        }.frame(width: 112, height: 72)
    }
}

//MARK: - Preview Content

extension OpenAccountCardView.ViewModel {

    static let sample: OpenAccountCardView.ViewModel = .init(balance: 100, numberCard: "4444555566664345", currencySymbol: "$", icon: .init("Card RUB"))
}

// MARK: - Previews

struct OpenAccountCardViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        OpenAccountCardView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
            .padding(8)
    }
}
