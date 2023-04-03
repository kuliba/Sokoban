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
        
//        internal init(bankLogo: Image?, payee: OperationDetailViewModel.PayeeViewModel?, amount: OperationDetailViewModel.AmountViewModel, fee: OperationDetailViewModel.FeeViewModel?, description: String?, date: Date) {
//            
//            self.bankLogo = bankLogo
//            self.payee = payee
//            self.amount = amount
//            self.fee = fee
//            self.description = description
//            self.date = DateFormatter.operation.string(from: date)
//        }
        
        init(productStatement: ProductStatementData, model: Model) {

            let image = productStatement.svgImage?.image
            let dateFormatted = DateFormatter.operation.string(from: productStatement.tranDate ?? productStatement.date)

            switch productStatement.paymentDetailType {
            case .insideBank:
                let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchant)
                
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .betweenTheir:
                let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchant
                )
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .otherBank:
                let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchant)
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .contactAddressless, .direct:
                let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchant)
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .externalIndivudual, .externalEntity:
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                
                if let documentComment = productStatement.fastPayment?.documentComment, documentComment != "" {
                    
                    self.init(bankLogo: image, payee: nil, amount: amountViewModel, fee: nil, description: documentComment, date: dateFormatted)
                    
                } else {
                    
                    self.init(bankLogo: image, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                }
                
            case .housingAndCommunalService, .insideOther, .internet, .mobile:
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                self.init(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                 
            case .outsideCash:
                let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchant)
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                self.init(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .outsideOther:
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
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
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                if let documentComment = productStatement.fastPayment?.documentComment, documentComment != "" {
                    
                    self.init(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: documentComment, date: dateFormatted)
                    
                } else {
                    
                    self.init(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                }
            case .transport:
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
                self.init(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: dateFormatted)
                
            case .c2b:
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)

                let bankLogo = Self.bankLogo(with: productStatement, model: model)
                
                self.init(bankLogo: bankLogo, payee: .singleRow(productStatement.merchant), amount: amountViewModel, fee: nil, description: productStatement.fastPaymentComment, date: dateFormatted)
                
            default:
                //FIXME: taxes
                let amountViewModel = AmountViewModel(amount: productStatement.amount, currencyCodeNumeric: productStatement.currencyCodeNumeric, operationType: productStatement.operationType, payService: nil, model: model)
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
                
                if let feeViewModel = OperationDetailViewModel.FeeViewModel(with: operation, currencyCode: currencyCode)  {
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
                
                OperationDetailView.AmountView(viewModel: viewModel.amount)
                    .padding(.top, 32)
                
                if let payee = viewModel.payee {
                    
                    OperationDetailView.PayeeView(viewModel: payee)
                        .padding(.top, 8)
                }
                
                if let fee = viewModel.fee {
                    
                    OperationDetailView.FeeView(viewModel: fee)
                        .padding(.top, 32)
                }
                
                if let description = viewModel.description {
                    
                    CapsuleText(text: description, color: .black, bgColor: Color(hex: "F6F6F7"), font: .system(size: 18, weight: .regular))
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                }
                
                Text(viewModel.date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "999999"))
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
