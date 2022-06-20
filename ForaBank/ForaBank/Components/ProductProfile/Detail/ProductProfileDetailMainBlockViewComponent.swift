//
//  ProductProfileDetailMainBlockViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 18.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
    
    struct MainBlockViewModel {
  
        let items: [ProductProfileDetailView.ViewModel.AmountViewModel]
        let progress: ProductProfileDetailView.ViewModel.CircleProgressViewModel
        
        internal init(items: [AmountViewModel], progress: CircleProgressViewModel) {
            
            self.items = items
            self.progress = progress
        }

        init(loanData: ProductCardData.LoanBaseParamInfoData, model: Model, action: @escaping () -> Void) {
            
            let debtAmount = loanData.debtAmount ?? 0
            let availableAmountCurrent = loanData.availableExceedLimit ?? 0
            let availableAmountTotal = loanData.totalAvailableAmount ?? 0
            
            let progressValue = availableAmountTotal > 0 ? availableAmountCurrent / availableAmountTotal : 1
            
            let debtAmountFormatted = model.amountFormatted(amount: debtAmount, currencyCode: loanData.currencyCode, style: .normal) ?? String(debtAmount)
            let availableAmountCurrentFormatted = model.amountFormatted(amount: availableAmountCurrent, currencyCode: loanData.currencyCode, style: .normal) ?? String(availableAmountCurrent)
            let availableAmountTotalFormatted = model.amountFormatted(amount: availableAmountTotal, currencyCode: loanData.currencyCode, style: .normal) ?? String(availableAmountTotal)
  
            self.items = [
                .init(title: "Задолженность", value: debtAmountFormatted, prefix: .legend(.textPlaceholder)),
                .init(title: "Доступно", value: availableAmountCurrentFormatted, prefix: .legend(.mainColorsRed), postfix: .value(availableAmountTotalFormatted))
            ]
            
            self.progress = .init(progress: progressValue, primaryColor: .mainColorsRed, secondaryColor: .textPlaceholder, action: action)
        }
    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct MainBlockView: View {
        
        let viewModel: ProductProfileDetailView.ViewModel.MainBlockViewModel
        
        var body: some View {
            
            HStack {
                
                VStack {
                    
                    ForEach(viewModel.items) { itemViewModel in
                        
                        ProductProfileDetailView.AmountView(viewModel: itemViewModel)
                        
                    }
                }
                
                ProductProfileDetailView.CircleProgressView(viewModel: viewModel.progress)
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailMainBlockViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ZStack {
                
                Color.black
                
                VStack(spacing: 40) {
                   
                    ProductProfileDetailView.MainBlockView(viewModel: .sampleCreditCard)
                        .frame(height: 112)
                    
                    ProductProfileDetailView.MainBlockView(viewModel: .sampleCredit)
                        .frame(height: 112)
                    
                }
                .padding(.horizontal, 20)
                
            }.previewLayout(.fixed(width: 375, height: 300))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.MainBlockViewModel {
    
    static let sampleCreditCard = ProductProfileDetailView.ViewModel.MainBlockViewModel(items: [.sampleLegendCreditCardOne, .sampleLegendCreditCardTwo], progress: .sampleCreditCard)
    
    static let sampleCredit = ProductProfileDetailView.ViewModel.MainBlockViewModel(items: [.sampleLegendCreditOne, .sampleLegendCreditTwo], progress: .sampleCredit)
}

extension ProductProfileDetailView.ViewModel.AmountViewModel {

    
    static let sampleLegendCreditCardOne = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Задолженность", value: "60 000 ₽", prefix: .legend(.textPlaceholder))
    
    static let sampleLegendCreditCardTwo = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Доступно", value: "240 000 ₽", prefix: .legend(.mainColorsRed), postfix: .value("300 000 ₽"))
    
    static let sampleLegendCreditOne = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Собственные средства", value: "60 056 ₽", prefix: .legend(.mainColorsWhite))
    
    static let sampleLegendCreditTwo = ProductProfileDetailView.ViewModel.AmountViewModel(title: "Кредитный лимит", value: "34 056 ₽", prefix: .legend(.mainColorsRed), postfix: .value("250 000 ₽"))
}

extension ProductProfileDetailView.ViewModel.CircleProgressViewModel {
    
    static let sampleCreditCard = ProductProfileDetailView.ViewModel.CircleProgressViewModel(progress: 0.7, primaryColor: .mainColorsRed, secondaryColor: .textPlaceholder, action: {})
    
    static let sampleCredit = ProductProfileDetailView.ViewModel.CircleProgressViewModel(progress: 0.7, primaryColor: .mainColorsRed, secondaryColor: .mainColorsWhite, action: {})
}
