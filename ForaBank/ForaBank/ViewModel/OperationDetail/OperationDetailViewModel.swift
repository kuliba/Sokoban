//
//  OperationDetailViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation
import SwiftUI
import Combine

class OperationDetailViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var header: HeaderViewModel
    @Published var operation: OperationViewModel
    @Published var actionButtons: [ActionButtonViewModel]?
    @Published var featureButtons: [FeatureButtonViewModel]
    
    lazy var dismissAction: () -> Void = {[weak self] in
        self?.action.send(OperationDetailViewModelAction.Dismiss())
    }
    
    @Published var isLoading: Bool
    @Published var operationDetailInfoViewModel: OperationDetailInfoViewModel?
    
    private let animationDuration: Double = 0.5
    
    init?(productStatement: ProductStatementProxy, product: UserAllCardsModel) {

        let tranDateString = DateFormatter.operation.string(from: productStatement.tranDate)

        switch productStatement.paymentDetailType {
        case .betweenTheir, .insideBank, .otherBank:
            self.header = HeaderViewModel(logo: productStatement.svgImage, status: nil, title: productStatement.groupName, category: "Переводы")
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: productStatement.currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .contactAddressless, .direct:
            self.header = HeaderViewModel(logo: productStatement.svgImage, status: nil, title: productStatement.groupName, category: nil)
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: productStatement.currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .externalIndivudual, .externalEntity:
            self.header = HeaderViewModel(logo: productStatement.svgImage, status: nil, title: productStatement.groupName, category: nil)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: productStatement.currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
            
        case .housingAndCommunalService, .insideOther, .internet, .mobile:
            self.header = HeaderViewModel(logo: productStatement.svgImage, status: nil, title: productStatement.merchantName, category: "\(productStatement.groupName)")
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: productStatement.currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .notFinance:
            return nil

        case .outsideCash:
            self.header = HeaderViewModel(logo: productStatement.svgImage, status: nil, title: productStatement.groupName, category: "Прочие")
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: productStatement.currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .outsideOther:
            self.header = HeaderViewModel(logo: productStatement.svgImage, status: nil, title: productStatement.merchantName, category: "\(productStatement.groupName) (\(productStatement.mcc))")
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: productStatement.currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .sfp:
            let sfpLogoImage = Image("Operation Type SFP Icon")
            self.header = HeaderViewModel(logo: sfpLogoImage, status: nil, title: productStatement.groupName, category: nil)
            var payeeViewModel: PayeeViewModel
            
            if let foreignPhoneNumber = productStatement.foreignPhoneNumber?.replacingOccurrences(of: " ", with: "") {
                
                let phoneFormatter = PhoneNumberFormater()
                let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                payeeViewModel = .doubleRow(productStatement.merchantName, formattedPhone)
                
            } else {
                
                payeeViewModel = .singleRow(productStatement.merchantName)
            }
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: productStatement.currencyCode, operationType: productStatement.operationType, payService: nil)
            if let documentComment = productStatement.documentComment, documentComment != "" {
                
                self.operation = OperationViewModel(bankLogo: productStatement.svgImage, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: documentComment, date: tranDateString)
           
            } else {
                
                self.operation = OperationViewModel(bankLogo: productStatement.svgImage, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            }
        }
        
        self.actionButtons = nil
        self.featureButtons = []
        self.isLoading = true
        
        if let infoFeatureButtonViewModel = infoFeatureButtonViewModel(with: productStatement, product: product) {
            
            self.featureButtons = [infoFeatureButtonViewModel]
        }
        
        fetchOperationDetail(productStatement: productStatement, product: product)
    }
    
    private func fetchOperationDetail(productStatement: ProductStatementProxy, product: UserAllCardsModel) {
        
        guard let documentId = productStatement.documentId else {
            
            withAnimation(.easeInOut(duration: self.animationDuration)) {
                
                self.isLoading = false
            }
            
            return
        }
        
        let body = [ "documentId" : documentId] as [String : AnyObject]
        
        NetworkManager<GetOperationDetailDecodebleModel>.addRequest(.getOperationDetail, [:], body) { [weak self] model, error in
            
            guard let self = self else {
                return
            }
            
            withAnimation(.easeInOut(duration: self.animationDuration)) {
                
                self.isLoading = false
            }
            
            guard error == nil, let model = model, model.statusCode == 0, let operationDetail = model.data else {
                return
            }
            
            DispatchQueue.main.async {
                
                //FIXME: refactor more elegant way without self
                withAnimation(.easeInOut(duration: self.animationDuration)) {
                    
                    self.operation = self.operation.updated(with: productStatement, operation: operationDetail, viewModel: self)
                }
                
                var actionButtonsUpdated: [ActionButtonViewModel]? = nil
                var featureButtonsUpdated = [FeatureButtonViewModel]()
                
                switch productStatement.paymentDetailType {
                case .betweenTheir, .insideBank, .externalIndivudual, .externalEntity, .housingAndCommunalService, .otherBank, .internet, .mobile, .direct, .sfp:

                    if let templateButtonViewModel = self.templateButtonViewModel(with: operationDetail) {
                        
                        featureButtonsUpdated.append(templateButtonViewModel)
                    }
                    
                    if let documentButtonViewModel = self.documentButtonViewModel(with: operationDetail) {
                        
                        featureButtonsUpdated.append(documentButtonViewModel)
                    }
                    
                    if let infoButtonViewModel = self.infoFeatureButtonViewModel(with: productStatement, product: product, operationDetail: operationDetail) {
                        
                        featureButtonsUpdated.append(infoButtonViewModel)
                    }
                    
                case .contactAddressless:
                    if let templateButtonViewModel = self.templateButtonViewModel(with: operationDetail) {
                        
                        featureButtonsUpdated.append(templateButtonViewModel)
                    }
                    
                    if let documentButtonViewModel = self.documentButtonViewModel(with: operationDetail) {
                        
                        featureButtonsUpdated.append(documentButtonViewModel)
                    }
                    
                    if let infoButtonViewModel = self.infoFeatureButtonViewModel(with: productStatement, product: product, operationDetail: operationDetail) {
                        
                        featureButtonsUpdated.append(infoButtonViewModel)
                    }
                    
                    if operationDetail.transferReference != nil {
                        
                        actionButtonsUpdated = self.actionButtons(with: operationDetail, product: product)
                    }
                    
                default:
                    break
                }

                withAnimation(.easeInOut(duration: self.animationDuration)) {
                    
                    self.actionButtons = actionButtonsUpdated
                    self.featureButtons = featureButtonsUpdated
                }
            }
        }
    }
}

//MARK: - Private helpers

private extension OperationDetailViewModel {
    
    func infoFeatureButtonViewModel(with productStatement: ProductStatementProxy, product: UserAllCardsModel, operationDetail: OperationDetailDatum? = nil) -> FeatureButtonViewModel? {

        return FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: { [weak self] in self?.operationDetailInfoViewModel = OperationDetailInfoViewModel(with: productStatement, operation: operationDetail, product: product, dismissAction: { [weak self] in self?.operationDetailInfoViewModel = nil})})
    }
    
    func documentButtonViewModel(with operationDetail: OperationDetailDatum) -> FeatureButtonViewModel? {
        
        guard let paymentOperationDetailID = operationDetail.paymentOperationDetailID, let printFormType = operationDetail.printFormType else {
            return nil
        }
        
        return FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: { [weak self] in self?.action.send(OperationDetailViewModelAction.ShowDocument(paymentOperationDetailID: paymentOperationDetailID, printFormType: printFormType))})
    }
    
    func templateButtonViewModel(with operationDetail: OperationDetailDatum) -> FeatureButtonViewModel? {
        
        //FIXME: temp mock
        return FeatureButtonViewModel(kind: .template(false), icon: "Operation Details Template", name: "+ Шаблон", action: {})
    }
    
    func actionButtons(with operationDetail: OperationDetailDatum, product: UserAllCardsModel) -> [ActionButtonViewModel] {
        
        var actionButtons = [ActionButtonViewModel]()
        
        let changeButton = ActionButtonViewModel(name: "Изменить",
                                                 action: { [weak self] in
            self?.action.send(OperationDetailViewModelAction.Change(
                amount: (operationDetail.amount ?? 0).currencyFormatter(symbol: operationDetail.currencyAmount ?? ""),
                name: operationDetail.payeeFirstName ?? "",
                surname: operationDetail.payeeSurName ?? "",
                secondName: operationDetail.payeeMiddleName ?? "",
                paymentOperationDetailId: operationDetail.paymentOperationDetailID ?? 0,
                transferReference: operationDetail.transferReference ?? "",
                product: product)
            )
        })
        actionButtons.append(changeButton)
        
        let returnButton = ActionButtonViewModel(name: "Вернуть",
                                                 action: { [weak self] in
            self?.action.send(OperationDetailViewModelAction.Return(
                amount: (operationDetail.amount ?? 0).currencyFormatter(symbol: operationDetail.currencyAmount ?? ""),
                fullName: operationDetail.payeeFullName ?? "",
                name: operationDetail.payeeFirstName ?? "",
                surname: operationDetail.payeeSurName ?? "",
                secondName: operationDetail.payeeMiddleName ?? "",
                paymentOperationDetailId: operationDetail.paymentOperationDetailID ?? 0,
                transferReference: operationDetail.transferReference ?? "",
                product: product)
            )
        })
        actionButtons.append(returnButton)
        
        return actionButtons
    }
}

//MARK: - Types

extension OperationDetailViewModel {
    
    struct HeaderViewModel {
        
        let logo: Image
        let status: StatusViewModel?
        let title: String
        let category: String?
    }
    
    struct OperationViewModel {

        let bankLogo: Image?
        let payee: PayeeViewModel?
        let amount: AmountViewModel
        let fee: FeeViewModel?
        let description: String?
        let date: String
        
        internal init(bankLogo: Image?, payee: PayeeViewModel?, amount: AmountViewModel, fee: FeeViewModel?, description: String?, date: String) {
            
            self.bankLogo = bankLogo
            self.payee = payee
            self.amount = amount
            self.fee = fee
            self.description = description
            self.date = date
        }
        
        internal init(bankLogo: Image?, payee: PayeeViewModel?, amount: AmountViewModel, fee: FeeViewModel?, description: String?, date: Date) {
            
            self.bankLogo = bankLogo
            self.payee = payee
            self.amount = amount
            self.fee = fee
            self.description = description
            self.date = DateFormatter.operation.string(from: date)
        }
        
        func updated(with bankLogo: Image) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }

        func updated(with payee: PayeeViewModel) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }
        
        func updated(with fee: FeeViewModel) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }
        
        func updated(with date: String) -> OperationViewModel {
            
            OperationViewModel(bankLogo: bankLogo, payee: payee, amount: amount, fee: fee, description: description, date: date)
        }
        
        func updated(with productStatement: ProductStatementProxy, operation: OperationDetailDatum, viewModel: OperationDetailViewModel) -> OperationViewModel {
            
            var operationViewModel = self
            
            switch productStatement.paymentDetailType {
            case .contactAddressless:
                if let transferReference = operation.transferReference {

                    let payeeViewModel: PayeeViewModel = .number(productStatement.merchantName, transferReference, {[weak viewModel] in viewModel?.action.send(OperationDetailViewModelAction.CopyNumber(number: transferReference)) })
                    
                    operationViewModel = operationViewModel.updated(with: payeeViewModel)
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: productStatement.currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .direct:
                if let memberId = operation.memberID,
                   let bank = Dict.shared.banks?.first(where: { $0.memberID == memberId }),
                   let bankLogoSVG = bank.svgImage {
                    
                    let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                    operationViewModel = operationViewModel.updated(with: bankLogoImage)
                }
                
                if let payeePhone = operation.payeePhone {
                    let phoneFormatter = PhoneNumberFormater()
                    let formattedPhone = phoneFormatter.format(payeePhone)
                    operationViewModel = operationViewModel.updated(with: .doubleRow(productStatement.merchantName, formattedPhone))
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: productStatement.currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }

            case .externalIndivudual, .externalEntity:

                if let bankBic = operation.payeeBankBIC,
                   let bank = Dict.shared.bankFullInfoList?.first(where: {$0.bic == bankBic}),
                   let bankLogoSVG = bank.svgImage {
                    
                    
                    let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                    operationViewModel = operationViewModel.updated(with: bankLogoImage)
                }
                
                if let payeeFullName = operation.payeeFullName, let payeeAccountNumber = operation.payerAccountNumber {
                    
                    operationViewModel = operationViewModel.updated(with: .doubleRow(payeeFullName, payeeAccountNumber))
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: productStatement.currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .internet:
                if let account = operation.account {
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(account))
                }
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: productStatement.currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .mobile:
                if let payeePhone = operation.payeePhone {
                    let phoneFormatter = PhoneNumberFormater()
                    let formattedPhone = phoneFormatter.format(payeePhone)

                    operationViewModel = operationViewModel.updated(with: .singleRow(formattedPhone))
                }
                
            case .otherBank, .housingAndCommunalService:
                if let payeeCardNumber = operation.payeeCardNumber {
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(payeeCardNumber))
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: productStatement.currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .sfp:
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: productStatement.currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }

            case .outsideOther, .insideOther, .betweenTheir, .insideBank, .notFinance, .outsideCash:
                return operationViewModel
            }
  
            return operationViewModel
        }
    }
    
    enum PayeeViewModel {
        
        case singleRow(String)
        case doubleRow(String, String)
        case number(String, String, () -> Void)
    }
    
    struct AmountViewModel {
        
        let amount: String
        let payService: PayServiceViewModel?
        let colorHex: String
        
        init(amount: Double, currency: String, operationType: OperationType, payService: PayServiceViewModel?) {
            
            switch operationType {
            case .credit:
                self.amount = "+" + amount.currencyFormatter(symbol: currency)
                self.colorHex = "1C1C1C"
                
            case .debit:
                self.amount = "-" + amount.currencyFormatter(symbol: currency)
                self.colorHex = "1C1C1C"
            }
            
            self.payService = payService
        }
    }
    
    struct FeeViewModel {

        let title: String
        let amount: String
        
        internal init(title: String, amount: String) {
            self.title = title
            self.amount = amount
        }
        
        init?(with operation: OperationDetailDatum, currencyCode: String) {
            
            guard let feeAmount = operation.payerFee, feeAmount > 0 else {
                return nil
            }
            
            //FIXME: localization required
            self.title = "Из них комиссия:"
            self.amount = feeAmount.currencyFormatter(symbol: currencyCode)
        }
    }

    enum PayServiceViewModel {
        
        case applePay
        case googlePay
        case payWay
        
        var iconName: String {
            
            switch self {
            case .applePay: return "ApplePay Icon"
            case .googlePay: return "GooglePay Icon"
            case .payWay: return "PayWay Icon"
            }
        }
    }
    
    enum StatusViewModel {
        
        case reject
        case success
        case processing
        
        //FIXME: localization required
        var name: String {
            
            switch self {
            case .reject: return "Отказ!"
            case .success: return "Успешно!"
            case .processing: return "В обработке"
            }
        }
        
        //FIXME: move to assets
        var colorHex: String {
            
            switch self {
            case .reject: return "#E3011B"
            case .success: return "#22C183"
            case .processing: return "#FF9636"
            }
        }
    }
    
    struct ActionButtonViewModel: Identifiable {
        
        let id = UUID()
        let name: String
        let action: () -> Void
    }
    
    struct FeatureButtonViewModel: Identifiable {

        let id = UUID()
        let kind: Kind
        let icon: String
        let name: String
        let action: () -> Void
        
        enum Kind {
        case template(Bool)
        case document
        case info
        }
    }
}

//MARK: - convenience inits

extension OperationDetailViewModel {
    
    convenience init?(with statement: GetDepositStatementDatum, currency: String, product: UserAllCardsModel) {
        
        guard let paymentDetailType = statement.paymentDetailType,
        let svgImageData = statement.svgImage,
        let groupName = statement.groupName,
        let amount = statement.amount else {
            return nil
        }
        
        let documentId = statement.documentID
        let svgImage = Image(uiImage: svgImageData.convertSVGStringToImage())
        let merchantName = (statement.merchantNameRus ?? statement.merchantName) ?? ""
        let mcc = statement.mcc ?? 0
        let tranDate = statement.transactionDate
        let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber
        let documentComment = statement.fastPayment?.documentComment
        let operationType = statement.operationTypeEnum
        
        let productStatement = ProductStatementProxy(paymentDetailType: paymentDetailType, documentId: documentId, svgImage: svgImage, merchantName: merchantName, groupName: groupName, mcc: mcc, amount: amount, currencyCode: currency, tranDate: tranDate, foreignPhoneNumber: foreignPhoneNumber, documentComment: documentComment, operationType: operationType, fastPayment: statement.fastPayment, comment: statement.comment)
        
        self.init(productStatement: productStatement, product: product)
    }
    
    convenience init?(with statement: GetCardStatementDatum, currency: String, product: UserAllCardsModel) {
        
        guard let paymentDetailType = statement.paymentDetailType,
        let svgImageData = statement.svgImage,
        let groupName = statement.groupName,
        let amount = statement.amount else {
            return nil
        }
        
        let documentId = statement.documentID
        let svgImage = Image(uiImage: svgImageData.convertSVGStringToImage())
        let merchantName = (statement.merchantNameRus ?? statement.merchantName) ?? ""
        let mcc = statement.mcc ?? 0
        let tranDate = statement.transactionDate
        let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber
        let documentComment = statement.fastPayment?.documentComment
        let operationType = statement.operationTypeEnum
        
        let productStatement = ProductStatementProxy(paymentDetailType: paymentDetailType, documentId: documentId, svgImage: svgImage, merchantName: merchantName, groupName: groupName, mcc: mcc, amount: amount, currencyCode: currency, tranDate: tranDate, foreignPhoneNumber: foreignPhoneNumber, documentComment: documentComment, operationType: operationType, fastPayment: statement.fastPayment, comment: statement.comment)
        
        self.init(productStatement: productStatement, product: product)
    }
    
    convenience init?(with statement: GetAccountStatementDatum, currency: String, product: UserAllCardsModel) {
        
        guard let paymentDetailType = statement.paymentDetailType,
        let svgImageData = statement.svgImage,
        let groupName = statement.groupName,
        let amount = statement.amount else {
            return nil
        }
        
        let documentId = statement.documentID
        let svgImage = Image(uiImage: svgImageData.convertSVGStringToImage())
        let merchantName = (statement.merchantNameRus ?? statement.merchantName) ?? ""
        let mcc = statement.mcc ?? 0
        let tranDate = statement.transactionDate
        let foreignPhoneNumber = statement.fastPayment?.foreignPhoneNumber
        let documentComment = statement.fastPayment?.documentComment
        let operationType = statement.operationTypeEnum
        
        let productStatement = ProductStatementProxy(paymentDetailType: paymentDetailType, documentId: documentId, svgImage: svgImage, merchantName: merchantName, groupName: groupName, mcc: mcc, amount: amount, currencyCode: currency, tranDate: tranDate, foreignPhoneNumber: foreignPhoneNumber, documentComment: documentComment, operationType: operationType, fastPayment: statement.fastPayment, comment: statement.comment)
        
        self.init(productStatement: productStatement, product: product)
    }
}

//MARK: - Samples

extension OperationDetailViewModel {
    
    static let sampleComplete: OperationDetailViewModel = {
        
        var viewModel = OperationDetailViewModel(productStatement: .init(paymentDetailType: .sfp, documentId: 0, svgImage: Image(uiImage: UIImage(named: "Operation Group Sample")!), merchantName: "Merchant Name", groupName: "Group Name", mcc: 234, amount: 1234, currencyCode: "RUS", tranDate: Date(), foreignPhoneNumber: nil, documentComment: nil, operationType: .debit, fastPayment: nil, comment: nil), product: UserAllCardsModel())!
        
        viewModel.header = HeaderViewModel(logo: viewModel.header.logo, status: .success, title: viewModel.header.title,  category: viewModel.header.category)
        
        viewModel.operation = OperationViewModel(bankLogo: Image(uiImage: UIImage(named: "Bank Logo Sample")!), payee: .number("Иванов Иван Иванович", "4556676767", {}), amount: .init(amount: 1000.25, currency: "RUB", operationType: .debit, payService: .applePay), fee: .init(title: "Комиссия:", amount: "50,00"), description: "Описание операции", date: viewModel.operation.date)
        
        viewModel.actionButtons = [ActionButtonViewModel(name: "Изменить", action: {}), ActionButtonViewModel(name: "Вернуть", action: {})]
        
        viewModel.featureButtons = [FeatureButtonViewModel(kind: .template(false), icon: "Operation Details Template", name: "+ Шаблон", action: {}), FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: {})]
        
        return viewModel
        
    }()
    
    static let sampleMin: OperationDetailViewModel = {
       
        var viewModel = OperationDetailViewModel(productStatement: .init(paymentDetailType: .sfp, documentId: 0, svgImage: Image(uiImage: UIImage(named: "Operation Group Sample")!), merchantName: "Merchant Name", groupName: "Group Name", mcc: 234, amount: 1234, currencyCode: "RUS", tranDate: Date(), foreignPhoneNumber: nil, documentComment: nil, operationType: .debit, fastPayment: nil, comment: nil), product: UserAllCardsModel())!
        
        viewModel.header = HeaderViewModel(logo: viewModel.header.logo, status: nil, title: viewModel.header.title,  category: nil)
        
        viewModel.operation = OperationViewModel(bankLogo: nil, payee: .singleRow("Иванов"), amount: .init(amount: 1000.25, currency: "RUB", operationType: .debit, payService: nil), fee: nil, description: nil, date: viewModel.operation.date)
        
        viewModel.actionButtons = nil
        
        viewModel.featureButtons = [FeatureButtonViewModel(kind: .template(false), icon: "Operation Details Template", name: "+ Шаблон", action: {}), FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: {})]
        
        return viewModel
        
    }()
}

//FIXME: remove after refactoring server API models
struct ProductStatementProxy {
    
    let paymentDetailType: PaymentDetailType
    let documentId: Int?
    let svgImage: Image
    let merchantName: String
    let groupName: String
    let mcc: Int
    let amount: Double
    let currencyCode: String
    let tranDate: Date
    let foreignPhoneNumber: String?
    let documentComment: String?
    let operationType: OperationType
    let fastPayment: FastPaymentData?
    let comment: String?
}
