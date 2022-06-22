//
//  ProductProfileDetailFooterViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 17.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
    
    struct FooterViewModel {

        let items: [ProductProfileDetailView.ViewModel.AmountViewModel]
        
        internal init(items: [ProductProfileDetailView.ViewModel.AmountViewModel]) {
            
            self.items = items
        }
        
        init?(configuration: ProductProfileDetailView.ViewModel.Configuration, loanData: ProductCardData.LoanBaseParamInfoData, model: Model) {
            
            var items = [ProductProfileDetailView.ViewModel.AmountViewModel]()
            
            switch configuration {
            case .minimumPaymentAndGrasePeriod:
     
                let minimumPayment = model.amountFormatted(amount: loanData.minimumPaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.minimumPaymentValue)
                let gracePeriodPayment = model.amountFormatted(amount: loanData.gracePeriodPaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.gracePeriodPaymentValue)
                let totalDebtAmount = model.amountFormatted(amount: loanData.totalDebtAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.totalDebtAmountValue)
                
                items.append(.init(type: .minimalPayment, value: minimumPayment, backgroundColor: .mainColorsBlackMedium))
                items.append(.init(type: .gracePayment, value: gracePeriodPayment))
                items.append(.init(type: .totalDebt, value: totalDebtAmount))

            case .overdue:
                let minimumPayment = model.amountFormatted(amount: loanData.minimumPaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.minimumPaymentValue)
                let overduePayment = model.amountFormatted(amount: loanData.overduePaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.overduePaymentValue)
                let totalDebtAmount = model.amountFormatted(amount: loanData.totalDebtAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.totalDebtAmountValue)
                let gracePeriodPayment = model.amountFormatted(amount: loanData.gracePeriodPaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.gracePeriodPaymentValue)
                
                items.append(.init(type: .minimalPayment, value: minimumPayment, backgroundColor: .mainColorsBlackMedium))
                items.append(.init(type: .includingDelay, value: overduePayment, postfix: .info(color: .iconRed, action: {})))
                items.append(.init(type: .totalDebt, value: totalDebtAmount))
                items.append(.init(type: .gracePayment, value: gracePeriodPayment, postfix: .info(color: .mainColorsGray, action: {})))
    
            case .loanRepaidAndOwnFunds:
                let availableValue = loanData.availableExceedLimitValue + loanData.ownFundsValue
                
                let available = model.amountFormatted(amount: availableValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(availableValue)
                
                items.append(.init(type: .available, value: available))
                
            case .entireLoanUsed, .overdraft, .withoutGrasePeriod:
                let minimumPayment = model.amountFormatted(amount: loanData.minimumPaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.minimumPaymentValue)
                let totalDebtAmount = model.amountFormatted(amount: loanData.totalDebtAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.totalDebtAmountValue)
                
                items.append(.init(type: .minimalPayment, value: minimumPayment, backgroundColor: .mainColorsBlackMedium))
                items.append(.init(type: .totalDebt, value: totalDebtAmount))
                
            case .minimumPaymentMade:
                let totalDebtAmount = model.amountFormatted(amount: loanData.totalDebtAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.totalDebtAmountValue)
                
                items.append(.init(type: .minimalPayment, value: "Внесен", postfix: .checkmark, backgroundColor: .mainColorsBlackMedium))
                items.append(.init(type: .totalDebt, value: totalDebtAmount))
                
            case .withoutGrasePeriodWithOverdue:
                let minimumPayment = model.amountFormatted(amount: loanData.minimumPaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.minimumPaymentValue)
                let overduePayment = model.amountFormatted(amount: loanData.overduePaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.overduePaymentValue)
                let totalDebtAmount = model.amountFormatted(amount: loanData.totalDebtAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.totalDebtAmountValue)
                
                items.append(.init(type: .minimalPayment, value: minimumPayment, backgroundColor: .mainColorsBlackMedium))
                items.append(.init(type: .includingDelay, value: overduePayment, postfix: .info(color: .iconRed, action: {})))
                items.append(.init(type: .totalDebt, value: totalDebtAmount))
                
            case .minimumPaymentMadeGrasePeriodRemain:
                let gracePeriodPayment = model.amountFormatted(amount: loanData.gracePeriodPaymentValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.gracePeriodPaymentValue)
                let totalDebtAmount = model.amountFormatted(amount: loanData.totalDebtAmountValue, currencyCode: loanData.currencyCode, style: .normal) ?? String(loanData.totalDebtAmountValue)
                
                items.append(.init(type: .minimalPayment, value: "Внесен", postfix: .checkmark, backgroundColor: .mainColorsBlackMedium))
                items.append(.init(type: .gracePayment, value: gracePeriodPayment))
                items.append(.init(type: .totalDebt, value: totalDebtAmount))
                
            default:
                return nil
            }
            
            self.items = items
        }
        
        init(productLoan: ProductLoanData, loanData: PersonsCreditData, model: Model) {
            
            var items = [ProductProfileDetailView.ViewModel.AmountViewModel]()
            
            let amountPayment = model.amountFormatted(amount: loanData.amountPaymentValue, currencyCode: productLoan.currency, style: .normal) ?? String(loanData.amountPaymentValue)
            
            items.append(.init(type: .makePayment, value: amountPayment, backgroundColor: .mainColorsBlackMedium))
            
            if loanData.overduePaymentValue > 0 {
                
                let amountOverdue = model.amountFormatted(amount: loanData.overduePaymentValue, currencyCode: productLoan.currency, style: .normal) ?? String(loanData.overduePaymentValue)
                items.append(.init(type: .includingDelay, value: amountOverdue, postfix: .info(color: .iconRed, action: {})))
            }
            
            self.items = items
        }
    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct FooterView: View {
        
        let viewModel: ProductProfileDetailView.ViewModel.FooterViewModel
        
        var body: some View {
            
            if #available(iOS 14, *) {
                
                LazyVGrid(columns: [.init(.flexible(), spacing: 20), .init(.flexible())], alignment: .leading, spacing: 20) {
                    
                    ForEach(viewModel.items) { itemViewModel in
                        
                        ProductProfileDetailView.AmountView(viewModel: itemViewModel)
                            .frame(height: 54)
                    }
                }
                
            } else {
                
                //TODO: real implementation required
                HStack(spacing: 4) {
                    
                    ForEach(viewModel.items) { item in
                        
                        ProductProfileDetailView.AmountView(viewModel: item)
                            .frame(height: 54)
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailFooterViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            
            Color.black
            
            ProductProfileDetailView.FooterView(viewModel: .sample)
                .padding(.horizontal, 20)
        }
        .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.FooterViewModel {
    
    static let sample = ProductProfileDetailView.ViewModel.FooterViewModel(items: [.sampleBackground, .sampleInfo, .sampleCheckmark, .sample])
}
