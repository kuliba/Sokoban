//
//  PaymentsCardViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension PaymentsCardView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let title: String
        @Published var cardIcon: Image
        @Published var paymentSystemIcon: Image?
        @Published var name: String
        @Published var amount: String
        @Published var captionItems: [CaptionItemViewModel]
        
        @Published var state: State
        
        static let cardIconPlaceholder = Image("Placeholder Card Small")
        
        init(title: String, cardIcon: Image, paymentSystemIcon: Image?, name: String, amount: String, captionItems: [CaptionItemViewModel], state: State, parameterCard: Payments.ParameterCard = .init()) {
            
            self.title = title
            self.cardIcon = cardIcon
            self.paymentSystemIcon = paymentSystemIcon
            self.name = name
            self.amount = amount
            self.captionItems = captionItems
            self.state = state
            
            super.init(source: parameterCard)
        }

        init(with parameterCard: Payments.ParameterCard) {
            
            self.title = ""
            self.cardIcon = Self.cardIconPlaceholder
            self.paymentSystemIcon = nil
            self.name = ""
            self.amount = ""
            self.captionItems = []
            self.state = .normal
            
            super.init(source: parameterCard)
        }
        
        enum State {
            
            case normal
            case expanded(PaymentsProductSelectorView.ViewModel)
        }
        
        struct CaptionItemViewModel: Identifiable {
            
            let id = UUID()
            let title: String
        }
    }
}

//MARK: - View

struct PaymentsCardView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .padding(.leading, 48)
            
            HStack(alignment: .top, spacing: 16) {
               
                viewModel.cardIcon
                    .resizable()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(alignment: .center, spacing: 10) {
                        
                        viewModel.paymentSystemIcon
                            .frame(width: 24, height: 24)
                        
                        Text(viewModel.name)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text(viewModel.amount)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                        
                        Image.ic24ChevronDown
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.mainColorsGray)
                    }
                    
                    HStack {
                      
                        ForEach(viewModel.captionItems) { itemViewModel in
                            
                            PaymentsCardView.CaptionItemView(viewModel: itemViewModel)
                        }
                    }
                }
            }
            
            switch viewModel.state {
            case .normal:
                EmptyView()
                
            case .expanded(let productSelectorViewModel):
                PaymentsProductSelectorView(viewModel: productSelectorViewModel)
                    .padding(.top, 8)
            }
        }
    }
}

extension PaymentsCardView {
    
    struct CaptionItemView: View {
        
        let viewModel: ViewModel.CaptionItemViewModel
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                Circle()
                    .frame(width: 2, height: 2)
                    .foregroundColor(.mainColorsGray)
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
            }
        }
    }
}

//MARK: - Preview

struct PaymentsCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsCardView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 90))
            
            PaymentsCardView(viewModel: .sampleExpanded)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension PaymentsCardView.ViewModel {
    
    static let sample = PaymentsCardView.ViewModel(title: "Счет списания", cardIcon: cardIconPlaceholder, paymentSystemIcon: Image("card_mastercard_logo"), name: "Основная", amount: "170 897 ₽", captionItems: [.init(title: "4996"), .init(title: "Корпоротивная")], state: .normal)
    
    static let sampleExpanded = PaymentsCardView.ViewModel(title: "Счет списания", cardIcon: cardIconPlaceholder, paymentSystemIcon: Image("card_mastercard_logo"), name: "Основная", amount: "170 897 ₽", captionItems: [.init(title: "4996"), .init(title: "Корпоротивная")], state: .expanded(.sample))
}



