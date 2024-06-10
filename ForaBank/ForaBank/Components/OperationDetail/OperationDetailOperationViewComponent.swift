//
//  OperationDetailOperationViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 30.06.2022.
//

import SwiftUI

//MARK: - View Model

extension OperationDetailViewModel {
    
    struct OperationViewModel {
        
        let bankLogo: Image?
        let payee: OperationDetailViewModel.PayeeViewModel?
        let amount: OperationDetailViewModel.AmountViewModel
        let fee: OperationDetailViewModel.FeeViewModel?
        let description: String?
        let date: String
        
        internal init(bankLogo: Image?, payee: OperationDetailViewModel.PayeeViewModel?, amount: OperationDetailViewModel.AmountViewModel, fee: OperationDetailViewModel.FeeViewModel?, description: String?, date: String) {
            
            self.bankLogo = bankLogo
            self.payee = payee
            self.amount = amount
            self.fee = fee
            self.description = description
            self.date = date
        }
        
        init(productStatement: ProductStatementData, model: Model) {
            
            let image = Self.bankLogo(with: productStatement, model: model)
            let dateFormatted = DateFormatter.operation.string(from: productStatement.tranDate ?? productStatement.date)
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchant)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
            
            switch productStatement.paymentDetailType {
            case .insideBank:
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .betweenTheir:
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .otherBank:
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .contactAddressless, .direct:
                self.init(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .externalIndivudual, .externalEntity:
                if let documentComment = productStatement.fastPayment?.documentComment, documentComment != "" {
                    
                    self.init(bankLogo: image, payee: nil, amount: amountViewModel, fee: nil, description: documentComment, date: dateFormatted)
                    
                } else {
                    
                    self.init(bankLogo: image, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                }
                
            case .housingAndCommunalService, .insideOther, .internet, .mobile:
                self.init(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .outsideCash:
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .outsideOther:
                self.init(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .sfp:
                var payeeViewModel: PayeeViewModel
                
                if let foreignPhoneNumber = productStatement.fastPayment?.foreignPhoneNumber.replacingOccurrences(of: " ", with: "") {
                    
                    let phoneFormatter = PhoneNumberKitFormater()
                    let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                    payeeViewModel = .doubleRow(productStatement.merchant, formattedPhone)
                    
                } else {
                    
                    payeeViewModel = .singleRow(productStatement.merchant)
                }
                if let documentComment = productStatement.fastPayment?.documentComment, documentComment != "" {
                    
                    self.init(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: documentComment, date: dateFormatted)
                    
                } else {
                    
                    self.init(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                }
                
            case .transport:
                self.init(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .c2b:
                let bankLogo = Self.bankLogo(with: productStatement, model: model)
                
                self.init(bankLogo: bankLogo, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: productStatement.fastPaymentComment, date: dateFormatted)
                
            case .sberQRPayment:
                self.init(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            default:
                //FIXME: taxes
                self.init(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
            }
        }
        
        static func bankLogo(with statement: ProductStatementData, model: Model) -> Image? {
            
            guard let bic = statement.fastPayment?.foreignBankBIC,
                  let bankInfo = model.dictionaryFullBankInfoBank(for: bic) else {
                return nil
            }
            
            return bankInfo.svgImage.image
        }
        
        func updated(with bankLogo: Image) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }
        
        func updated(with payee: OperationDetailViewModel.PayeeViewModel) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }
        
        func updated(with fee: OperationDetailViewModel.FeeViewModel) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }
        
        func updated(with date: String) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }
        
        func updated(with productStatement: ProductStatementData, operation: OperationDetailData, viewModel: OperationDetailViewModel) -> OperationViewModel {
            
            var operationViewModel = self
            //FIXME: get currency from currencyList
            let currencyCode = "RUB"
            
            switch productStatement.paymentDetailType {
            case .contactAddressless:
                if let transferReference = operation.transferReference {
                    let titleNumber = "Номер перевода:"
                    let payeeViewModel: OperationDetailViewModel.PayeeViewModel = .number(productStatement.merchant, titleNumber, transferReference, {[weak viewModel] in viewModel?.action.send(OperationDetailViewModelAction.CopyNumber(number: transferReference)) })
                    
                    operationViewModel = operationViewModel.updated(with: payeeViewModel)
                }
                
                if let feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: operation.payerCurrency)  {
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .direct:
                if let memberId = operation.memberId,
                   let bank = Dict.shared.banks?.first(where: { $0.memberID == memberId }),
                   let bankLogoSVG = bank.svgImage {
                    
                    let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                    operationViewModel = operationViewModel.updated(with: bankLogoImage)
                }
                
                if let payeePhone = operation.payeePhone {
                    let phoneFormatter = PhoneNumberKitFormater()
                    let formattedPhone = phoneFormatter.format(payeePhone)
                    operationViewModel = operationViewModel.updated(with: .doubleRow(productStatement.merchant, formattedPhone))
                }
                
                if let feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .externalIndivudual, .externalEntity:
                
                if let bankBic = operation.payeeBankBIC,
                   let bank = Dict.shared.bankFullInfoList?.first(where: {$0.bic == bankBic}),
                   let bankLogoSVG = bank.svgImage {
                    
                    
                    let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                    operationViewModel = operationViewModel.updated(with: bankLogoImage)
                }
                
                if let payeeFullName = operation.payeeFullName, let payeeAccountNumber = operation.payeeAccountNumber {
                    
                    operationViewModel = operationViewModel.updated(with: .doubleRow(payeeFullName, payeeAccountNumber))
                }
                
                if var feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    feeViewModel.title = "Комиссия:"
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .internet:
                if let feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .mobile:
                if let payeePhone = operation.payeePhone {
                    let phoneFormatter = PhoneNumberKitFormater()
                    let formattedPhone = phoneFormatter.format(payeePhone)
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(formattedPhone))
                }
                
                if let feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .otherBank, .housingAndCommunalService:
                if let payeeCardNumber = operation.payeeCardNumber {
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(payeeCardNumber))
                }
                
                if let feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .sfp:
                if var feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    feeViewModel.title = "Комиссия:"
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
            case .transport:
                if let feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
            case .outsideOther, .insideOther, .betweenTheir, .insideBank, .notFinance, .outsideCash:
                return operationViewModel
            default:
                //FIXME: taxes & c2b
                return operationViewModel
            }
            
            return operationViewModel
        }
    }
}

//MARK: - View

extension OperationDetailView {
    
    struct OperationView: View {
        
        let viewModel: OperationDetailViewModel.OperationViewModel
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                if let logo = viewModel.bankLogo {
                    
                    logo.resizable().frame(width: 32, height: 32)
                }
                
                if let payee = viewModel.payee {
                    
                    OperationDetailView.PayeeView(viewModel: payee)
                        .padding(.top, 8)
                }
                
                OperationDetailView.AmountView(viewModel: viewModel.amount)
                    .padding(.top, 32)
                
                if let fee = viewModel.fee {
                    
                    OperationDetailView.FeeView(viewModel: fee)
                        .padding(.top, 32)
                }
                
                if let description = viewModel.description, !description.isEmpty {
                    
                    CapsuleText(text: description, color: .textSecondary, bgColor: .mainColorsGrayLightest, font: .system(size: 18, weight: .regular))
                        .padding(24)
                }
                
                Text(viewModel.date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.textPlaceholder)
                    .padding(.top, 16)
            }
        }
    }
}

//MARK: - Preview

struct OperationDetailOperationViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperationDetailView.OperationView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 600))
    }
}

//MARK: - Preview Content

extension OperationDetailViewModel.OperationViewModel {
    
    static let sample = OperationDetailViewModel.OperationViewModel(bankLogo: nil, payee: nil, amount: .init(amount: "30,5 $", payService: .applePay, colorHex: "1C1C1C"), fee: nil, description: nil, date: "29.11.22")
}
