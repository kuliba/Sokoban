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

        init(
            configuration: ProductProfileDetailView.ViewModel.Configuration,
            productCard: ProductCardData,
            loanData: ProductCardData.LoanBaseParamInfoData,
            amountFormatted: (Double, String?, Model.AmountFormatStyle) -> String?,
            action: @escaping () -> Void
        ) {
            
            switch configuration {
            case .loanRepaidAndOwnFunds:
                let progressValue = productCard.balanceValue > 0 ? loanData.ownFundsValue / productCard.balanceValue : 1
                
                let ownFunds = amountFormatted(loanData.ownFundsValue, loanData.currencyCode, .normal) ?? String(loanData.ownFundsValue)
                let creditLimit = productCard.balanceValue - loanData.ownFundsValue
                let balance = amountFormatted(creditLimit, loanData.currencyCode, .normal) ?? String(creditLimit)
                let totalAvailableAmount = loanData.totalAvailableAmountValue
                let available = amountFormatted(totalAvailableAmount, loanData.currencyCode, .normal) ?? String(productCard.balanceValue)
                
                self.items = [
                    .init(type: .ownFunds, value: ownFunds, prefix: .legend(.mainColorsWhite)),
                    .init(type: .loanLimit, value: balance, prefix: .legend(.mainColorsRed), postfix: .value(available))
                ]
                
                self.progress = .init(progress: progressValue, primaryColor: .mainColorsRed, secondaryColor: .mainColorsWhite , action: action)
                
            default:
                
                let progressValue = loanData.totalAvailableAmountValue > 0 ? loanData.debtAmountValue / loanData.totalAvailableAmountValue : 1
                
                let debtAmount = amountFormatted(loanData.debtAmountValue, loanData.currencyCode, .normal) ?? String(loanData.debtAmountValue)
                let creditLimit: Double = productCard.balanceValue - loanData.ownFundsValue
                let availableAmount = amountFormatted(creditLimit, loanData.currencyCode, .normal) ?? String(creditLimit)
                let totalAmount = amountFormatted(loanData.totalAvailableAmountValue,  loanData.currencyCode, .normal) ?? String(loanData.totalAvailableAmountValue)
      
                self.items = [
                    .init(type: .debt, value: debtAmount, prefix: .legend(.textPlaceholder)),
                    .init(type: .available, value: availableAmount, prefix: .legend(.mainColorsRed), postfix: .value(totalAmount))
                ]
                
                self.progress = .init(progress: progressValue, primaryColor: .mainColorsRed, secondaryColor: .bgIconBlack, action: action)
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
            
            self.progress = .init(progress: progressValue, primaryColor: .mainColorsRed, secondaryColor: .bgIconBlack, action: action)
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
