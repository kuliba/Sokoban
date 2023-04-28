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
        
        let accountTitle: String
        let balance: String
        @Published private(set) var numberCardLast: String?
        @Published var backgroudImage: Image?
        
        init(numberCardLast: String?, backgroudImage: Image?, accountTitle: String, balance: String) {
            
            self.numberCardLast = numberCardLast
            self.backgroudImage = backgroudImage
            self.accountTitle = accountTitle
            self.balance = balance
        }
        
        convenience init(balance: Double = 0,
                         numberCard: String? = nil,
                         accountTitle: String = "Текущий счет",
                         currencySymbol: String,
                         backgroudImage: Image?) {
            
            let balance = "\(balance.currencyDepositFormatter(symbol: currencySymbol))"
            self.init(numberCardLast: nil, backgroudImage: backgroudImage, accountTitle: accountTitle, balance: balance)
            update(with: numberCard)
        }
        
        func update(with numberCard: String?) {
            
            guard let numberCard = numberCard else {
                numberCardLast = nil
                return }
            numberCardLast = String(numberCard.suffix(4))
        }
    }
}

// MARK: - View

struct OpenAccountCardView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        ZStack {
            
            if let backgroudImage = viewModel.backgroudImage {
                
                backgroudImage
                    .resizable()
                    .frame(width: 112, height: 72)
                
            } else {
                
                Color.cardAccount
                    .cornerRadius(8)
                    .frame(width: 112, height: 72)
            }

            HStack {

                VStack(alignment: .leading, spacing: 5) {
                    
                    if let numberCard = viewModel.numberCardLast {
                        HStack(spacing: 3) {
                            
                            Circle()
                                .foregroundColor(.mainColorsWhite)
                                .frame(width: 2, height: 2)
                            
                            Text(numberCard)
                                .font(.textBodyXSR11140())
                                .foregroundColor(.mainColorsWhite)
                        }.padding(.leading, 29)
                    } else {
                        
                        Color.clear
                            .frame(height: 11)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        
                        Text(viewModel.accountTitle)
                            .font(.textBodyXSR11140())
                            .foregroundColor(.mainColorsGrayMedium)
                        
                        Text(viewModel.balance)
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
    
    static let sample: OpenAccountCardView.ViewModel = .init(balance: 100, numberCard: "4444555566664345", currencySymbol: "$", backgroudImage: .init("Card RUB"))
    
    static let sample_1: OpenAccountCardView.ViewModel = .init(balance: 100, currencySymbol: "₽", backgroudImage: .init("Card RUB"))
}

// MARK: - Previews

struct OpenAccountCardViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        Group {

            OpenAccountCardView(viewModel: .sample)
                .previewLayout(.sizeThatFits)
                .padding(8)
            
            OpenAccountCardView(viewModel: .sample_1)
                .previewLayout(.sizeThatFits)
                .padding(8)
        }
    }
}
