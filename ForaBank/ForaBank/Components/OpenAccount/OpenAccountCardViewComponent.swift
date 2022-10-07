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
        
        let balance: Double
        let currrentAccountTitle: String
        let currencyType: OpenAccountСurrencyType
        let currencyBalance: String

        var numberCardLast: String {
            
            if numberCard.isEmpty == false {
                return "• \(numberCard.suffix(4))"
            } else {
                return ""
            }
        }

        init(balance: Double = 0,
             numberCard: String = "",
             currrentAccountTitle: String = "Текущий счет",
             currencyType: OpenAccountСurrencyType) {

            self.balance = balance
            self.numberCard = numberCard
            self.currrentAccountTitle = currrentAccountTitle
            self.currencyType = currencyType

            currencyBalance = "\(balance.currencyDepositFormatter(symbol: currencyType.moneySign))"
        }
    }
}

// MARK: - View

struct OpenAccountCardView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        ZStack {

            Color.cardAccount

            HStack {

                Spacer()
                viewModel.currencyType.icon
            }

            HStack {

                VStack(alignment: .leading, spacing: 5) {

                    HStack(spacing: 3) {

                        viewModel.currencyType.iconDetail
                            .renderingMode(.original)
                            .resizable()
                            .foregroundColor(.mainColorsWhite)
                            .frame(width: 20, height: 20)

                        Text(viewModel.numberCardLast)
                            .font(.textBodyXSR11140())
                            .foregroundColor(.mainColorsWhite)
                    }

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
        }
        .cornerRadius(8)
        .frame(width: 112, height: 72)
    }
}

//MARK: - Preview Content

extension OpenAccountCardView.ViewModel {

    static let sample = OpenAccountCardView.ViewModel(
        numberCard: "4444555566664345",
        currencyType: .USD)
}

// MARK: - Previews

struct OpenAccountCardViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        OpenAccountCardView(viewModel: .sample)
            .padding()
            .background(Color.mainColorsGrayMedium)
            .previewLayout(.sizeThatFits)
    }
}
