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

        init(configuration: ProductProfileDetailView.ViewModel.Configuration, loanData: ProductCardData.LoanBaseParamInfoData, model: Model, action: @escaping () -> Void) {
            
            switch configuration {
            case .loanRepaidAndOwnFunds:
                let progressValue = loanData.availableExceedLimitValue > 0 ? loanData.ownFundsValue / loanData.availableExceedLimitValue : 1
                
                let ownFunds = model.amountFormatted(amount: loanData.ownFundsValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.ownFundsValue)
                let availableLimit = model.amountFormatted(amount: loanData.availableExceedLimitValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.availableExceedLimitValue)
                
                self.items = [
                    .init(type: .ownFunds, value: ownFunds, prefix: .legend(.mainColorsWhite)),
                    .init(type: .loanLimit, value: availableLimit, prefix: .legend(.mainColorsRed), postfix: .value(availableLimit))
                ]
                
                self.progress = .init(progress: progressValue, primaryColor: .mainColorsRed, secondaryColor: .mainColorsWhite, action: action)
                
            default:
                let progressValue = loanData.totalAvailableAmountValue > 0 ? loanData.debtAmountValue / loanData.totalAvailableAmountValue : 1
                
                let debtAmount = model.amountFormatted(amount: loanData.debtAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.debtAmountValue)
                let availableAmount = model.amountFormatted(amount: loanData.availableExceedLimitValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.availableExceedLimitValue)
                let totalAmount = model.amountFormatted(amount: loanData.totalAvailableAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.totalAvailableAmountValue)
      
                self.items = [
                    .init(type: .debt, value: debtAmount, prefix: .legend(.textPlaceholder)),
                    .init(type: .available, value: availableAmount, prefix: .legend(.mainColorsRed), postfix: .value(totalAmount))
                ]
                
                self.progress = .init(progress: progressValue, primaryColor: .mainColorsRed, secondaryColor: .textPlaceholder, action: action)
            }
        }
        
        init(productLoan: ProductLoanData, loanData: PersonsCreditData, model: Model, action: @escaping () -> Void) {
            
            let progressValue = loanData.amountCreditValue > 0 ? loanData.amountRepaidValue / loanData.amountCreditValue : 1
            
            let loanAmount = model.amountFormatted(amount: loanData.amountCreditValue, currencyCode: productLoan.currency, style: .normal) ?? String(loanData.amountCreditValue)
            let repaidAmount = model.amountFormatted(amount: loanData.amountRepaidValue, currencyCode: productLoan.currency, style: .normal) ?? String(loanData.amountRepaidValue)
            
            self.items = [
                .init(type: .loanAmount, value: loanAmount, prefix: .legend(.textPlaceholder)),
                .init(type: .repaid, value: repaidAmount, prefix: .legend(.mainColorsRed))
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

    
    static let sampleLegendCreditCardOne = ProductProfileDetailView.ViewModel.AmountViewModel(type: .debt, value: "60 000 ₽", prefix: .legend(.textPlaceholder))
    
    static let sampleLegendCreditCardTwo = ProductProfileDetailView.ViewModel.AmountViewModel(type: .available, value: "240 000 ₽", prefix: .legend(.mainColorsRed), postfix: .value("300 000 ₽"))
    
    static let sampleLegendCreditOne = ProductProfileDetailView.ViewModel.AmountViewModel(type: .ownFunds, value: "60 056 ₽", prefix: .legend(.mainColorsWhite))
    
    static let sampleLegendCreditTwo = ProductProfileDetailView.ViewModel.AmountViewModel(type: .loanLimit, value: "34 056 ₽", prefix: .legend(.mainColorsRed), postfix: .value("250 000 ₽"))
}

extension ProductProfileDetailView.ViewModel.CircleProgressViewModel {
    
    static let sampleCreditCard = ProductProfileDetailView.ViewModel.CircleProgressViewModel(progress: 0.7, primaryColor: .mainColorsRed, secondaryColor: .textPlaceholder, action: {})
    
    static let sampleCredit = ProductProfileDetailView.ViewModel.CircleProgressViewModel(progress: 0.7, primaryColor: .mainColorsRed, secondaryColor: .mainColorsWhite, action: {})
}
