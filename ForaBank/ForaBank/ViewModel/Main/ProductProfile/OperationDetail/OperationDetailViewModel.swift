//
//  OperationDetailViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation
import SwiftUI
import Combine

class OperationDetailViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    let id = UUID()
    @Published var header: HeaderViewModel
    @Published var operation: OperationViewModel
    @Published var actionButtons: [ActionButtonViewModel]?
    @Published var featureButtons: [FeatureButtonViewModel]
    
    lazy var dismissAction: () -> Void = {[weak self] in
        self?.action.send(OperationDetailViewModelAction.Dismiss())
    }
    
    @Published var isLoading: Bool
    @Published var operationDetailInfoViewModel: OperationDetailInfoViewModel?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    private let animationDuration: Double = 0.5
    private var paymentTemplateId: Int?
    
    init?(productStatement: ProductStatementData, product: ProductData, model: Model) {

        self.model = model
        
        let tranDateString = DateFormatter.operation.string(from: productStatement.tranDate)

        let currencyCode = self.model.currencyList.value.first(where: {$0.codeNumeric == productStatement.currencyCodeNumeric})?.code ?? "RUB"
        
        let image = productStatement.svgImage.image ?? .init(systemName: "")
        
        switch productStatement.paymentDetailType {
        case .insideBank:
             
            self.header = HeaderViewModel(logo: image, status: nil, title: "Перевод на карту", category: productStatement.groupName)
            
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .betweenTheir:
            
            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.groupName, category: "Переводы")
            
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .otherBank:

            self.header = HeaderViewModel(logo: image, status: nil, title: "Перевод на карту", category: productStatement.groupName)
            
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .contactAddressless, .direct:
                
            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.groupName, category: nil)

            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .externalIndivudual, .externalEntity:

            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.groupName, category: nil)
        
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            
            if let documentComment = productStatement.fastPayment?.documentComment, documentComment != "" {
                
                self.operation = OperationViewModel(bankLogo: image, payee: nil, amount: amountViewModel, fee: nil, description: documentComment, date: tranDateString)
           
            } else {
                
                self.operation = OperationViewModel(bankLogo: image, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            }
            
        case .housingAndCommunalService, .insideOther, .internet, .mobile:
            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.merchantName, category: "\(productStatement.groupName)")
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .notFinance:
            return nil

        case .outsideCash:
            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.groupName, category: "Прочие")
            let payeeViewModel: PayeeViewModel = .singleRow(productStatement.merchantName)
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .outsideOther:
            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.merchantName, category: "\(productStatement.groupName) (MCC \(productStatement.mcc))")
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            
        case .sfp:
            let sfpLogoImage = Image("Operation Type SFP Icon")
            self.header = HeaderViewModel(logo: sfpLogoImage, status: nil, title: productStatement.groupName, category: nil)
            var payeeViewModel: PayeeViewModel
            
            if let foreignPhoneNumber = productStatement.fastPayment?.foreignPhoneNumber.replacingOccurrences(of: " ", with: "") {
                
                let phoneFormatter = PhoneNumberFormater()
                let formattedPhone = phoneFormatter.format(foreignPhoneNumber)
                payeeViewModel = .doubleRow(productStatement.merchantName, formattedPhone)
                
            } else {
                
                payeeViewModel = .singleRow(productStatement.merchantName)
            }
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            if let documentComment = productStatement.fastPayment?.documentComment, documentComment != "" {
                
                self.operation = OperationViewModel(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: documentComment, date: tranDateString)
           
            } else {
                
                self.operation = OperationViewModel(bankLogo: image, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDateString)
            }
        case .transport:
            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.merchantName, category: "\(productStatement.groupName)")
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: productStatement.tranDate)
        case .c2b:
            let isReturn = productStatement.groupName.contains("Возврат")
            let allBanks = Dict.shared.bankFullInfoList
            let foundBank = allBanks?.filter({ $0.bic == productStatement.fastPayment?.foreignBankBIC })

            var imageBank: Image? = nil
            if foundBank != nil && foundBank?.count ?? 0 > 0 {
                let bankRusName = foundBank?[0].rusName ?? ""
                let bankIconSvg = foundBank?[0].svgImage ?? ""
                imageBank = Image(uiImage: bankIconSvg.convertSVGStringToImage())
            }
            
            var comment: String? = nil
            if  isReturn {
                comment = "Возврат по операции"
            } else {
                if productStatement.fastPayment?.documentComment.isEmpty != true {
                    comment = productStatement.fastPayment?.documentComment
                }
            }

            self.header = HeaderViewModel(
                logo: Image("sbpindetails"),
                status: isReturn ? StatusViewModel.purchase_return : StatusViewModel.success,
                title: "\(productStatement.groupName)",
                category: nil)
            
            let amountViewModel = AmountViewModel(
                amount: productStatement.amount,
                currency: currencyCode,
                operationType: productStatement.operationType,
                payService: nil)
                                                  
            self.operation = OperationViewModel(
                bankLogo: image ,
                payee: .singleRow(productStatement.merchantName),
                amount: amountViewModel,
                fee: nil,
                description: comment,
                date: productStatement.tranDate)
        default:
            //FIXME: taxes
            self.header = HeaderViewModel(logo: image, status: nil, title: productStatement.merchantName, category: "\(productStatement.groupName)")
            let amountViewModel = AmountViewModel(amount: productStatement.amount, currency: currencyCode, operationType: productStatement.operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: productStatement.tranDate)
        }

        self.actionButtons = nil
        self.featureButtons = []
        self.isLoading = true

        if let infoFeatureButtonViewModel = infoFeatureButtonViewModel(with: productStatement, product: product) {

            self.featureButtons = [infoFeatureButtonViewModel]
        }
        guard let documentId = productStatement.documentId else {
            return
        }
        model.action.send(ModelAction.Payment.OperationDetail.Request(documentId: documentId))
        bind()
    }

    private func bind() {

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {
                case _ as ModelAction.PaymentTemplate.Save.Complete:
                    var featureButtonsUpdated = [FeatureButtonViewModel]()
                    for buttonViewModel in featureButtons {
                        switch buttonViewModel.kind {
                        case .template:
                            let templateButtonSelected = FeatureButtonViewModel(kind: .template(true), icon: "Operation Details Template Selected", name: "Шаблон", action: {})
                            featureButtonsUpdated.append(templateButtonSelected)

                        default:
                            featureButtonsUpdated.append(buttonViewModel)
                        }
                    }
                    featureButtons = featureButtonsUpdated
                case _ as ModelAction.Payment.OperationDetail.Request:
                
                    break
                default:
                    break
                }

            }.store(in: &bindings)
    }
    
    private func fetchOperationDetail(productStatement: ProductStatementData, product: ProductData, operationDetail: OperationDetailData?) {
        
        guard let documentId = productStatement.documentId else {
            withAnimation(.easeInOut(duration: self.animationDuration)) {
                self.isLoading = false
            }
            return
        }
            
            withAnimation(.easeInOut(duration: self.animationDuration)) {
                self.isLoading = false
            }
            
            guard let operationDetail = operationDetail else {
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
                case .betweenTheir, .insideBank, .externalIndivudual, .externalEntity, .housingAndCommunalService, .otherBank, .internet, .mobile, .direct, .sfp, .transport, .c2b:
                    if let templateButtonViewModel = self.templateButtonViewModel(with: productStatement, operationDetail: operationDetail) {
                        featureButtonsUpdated.append(templateButtonViewModel)
                    }
                    if let documentButtonViewModel = self.documentButtonViewModel(with: operationDetail) {
                        featureButtonsUpdated.append(documentButtonViewModel)
                    }
                    if let infoButtonViewModel = self.infoFeatureButtonViewModel(with: productStatement, product: product, operationDetail: operationDetail) {
                        featureButtonsUpdated.append(infoButtonViewModel)
                    }
                case .contactAddressless:
                    if let templateButtonViewModel = self.templateButtonViewModel(with: productStatement, operationDetail: operationDetail) {
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

//MARK: - Private helpers

private extension OperationDetailViewModel {
    
    func infoFeatureButtonViewModel(with productStatement: ProductStatementData, product: ProductData, operationDetail: OperationDetailData? = nil) -> FeatureButtonViewModel? {
        return FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: { [weak self] in self?.operationDetailInfoViewModel = OperationDetailInfoViewModel(with: productStatement, operation: operationDetail, product: product, dismissAction: { [weak self] in self?.operationDetailInfoViewModel = nil})})
    }
    
    func documentButtonViewModel(with operationDetail: OperationDetailData) -> FeatureButtonViewModel? {
        
        let paymentOperationDetailID = operationDetail.paymentOperationDetailId
        let printFormType = operationDetail.printFormType
        
        return FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: {})
    }
    
    func templateButtonViewModel(with productStatement: ProductStatementData, operationDetail: OperationDetailData) -> FeatureButtonViewModel? {
        
        // check if template allowed for this operation type
        guard model.paymentTemplatesAllowed.contains(productStatement.paymentDetailType) else {
            return nil
        }
        
        if operationDetail.paymentTemplateId != nil {
            
            return FeatureButtonViewModel(kind: .template(true), icon: "Operation Details Template Selected", name: "Шаблон", action: {})
            
        } else {
            
            guard let name = templateName(with: productStatement, operationDetail: operationDetail) else {
                return nil
            }
            let paymentOperationDetailId = operationDetail.paymentOperationDetailId
            
            let action = ModelAction.PaymentTemplate.Save.Requested(name: name, paymentOperationDetailId: paymentOperationDetailId)
            return FeatureButtonViewModel(kind: .template(false), icon: "Operation Details Template", name: "+ Шаблон", action: { [weak self] in self?.model.action.send(action)})
        }
    }
    
    func templateName(with productStatement: ProductStatementData, operationDetail: OperationDetailData) -> String? {

        switch productStatement.paymentDetailType {
        case .betweenTheir, .insideBank, .housingAndCommunalService, .internet, .direct, .sfp, .contactAddressless:
            
            //TODO:  проверка на productStatement.merchantNameRus
            
            return productStatement.merchantName
            
        case .mobile :
            return operationDetail.payeePhone
            
        case .externalIndivudual, .externalEntity:
            return operationDetail.payeeFullName
            
        case .otherBank:
            return operationDetail.payeeCardNumber
        
        default:
            return nil
        }
    }
    
    func actionButtons(with operationDetail: OperationDetailData, product: ProductData) -> [ActionButtonViewModel] {
        
        var actionButtons = [ActionButtonViewModel]()
        
//        let changeButton = ActionButtonViewModel(name: "Изменить",
//                                                 action: { [weak self] in
//            self?.action.send(OperationDetailViewModelAction.Change(
//                amount: (operationDetail.amount ?? 0).currencyFormatter(symbol: operationDetail.currencyAmount ?? ""),
//                name: operationDetail.payeeFirstName ?? "",
//                surname: operationDetail.payeeSurName ?? "",
//                secondName: operationDetail.payeeMiddleName ?? "",
//                paymentOperationDetailId: operationDetail.paymentOperationDetailID ?? 0,
//                transferReference: operationDetail.transferReference ?? "",
//                product: product)
//            )
//        })
//        actionButtons.append(changeButton)
//
//        let returnButton = ActionButtonViewModel(name: "Вернуть",
//                                                 action: { [weak self] in
//            self?.action.send(OperationDetailViewModelAction.Return(
//                amount: (operationDetail.amount ?? 0).currencyFormatter(symbol: operationDetail.currencyAmount ?? ""),
//                fullName: operationDetail.payeeFullName ?? "",
//                name: operationDetail.payeeFirstName ?? "",
//                surname: operationDetail.payeeSurName ?? "",
//                secondName: operationDetail.payeeMiddleName ?? "",
//                paymentOperationDetailId: operationDetail.paymentOperationDetailID ?? 0,
//                transferReference: operationDetail.transferReference ?? "",
//                product: product)
//            )
//        })
//        actionButtons.append(returnButton)
        
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
        
        func updated(with productStatement: ProductStatementData, operation: OperationDetailData, viewModel: OperationDetailViewModel) -> OperationViewModel {
            
            var operationViewModel = self
            //FIXME: get currency from currencyList
            let currencyCode = "RUB"
            
            switch productStatement.paymentDetailType {
            case .contactAddressless:
                if let transferReference = operation.transferReference {
                    let titleNumber = "Номер перевода:"
                    let payeeViewModel: PayeeViewModel = .number(productStatement.merchantName, titleNumber, transferReference, {[weak viewModel] in viewModel?.action.send(OperationDetailViewModelAction.CopyNumber(number: transferReference)) })
                    
                    operationViewModel = operationViewModel.updated(with: payeeViewModel)
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
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
                    let phoneFormatter = PhoneNumberFormater()
                    let formattedPhone = phoneFormatter.format(payeePhone)
                    operationViewModel = operationViewModel.updated(with: .doubleRow(productStatement.merchantName, formattedPhone))
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
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
                
                if var feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    feeViewModel.title = "Комиссия:"
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .internet:
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .mobile:
                if let payeePhone = operation.payeePhone {
                    let phoneFormatter = PhoneNumberFormater()
                    let formattedPhone = phoneFormatter.format(payeePhone)

                    operationViewModel = operationViewModel.updated(with: .singleRow(formattedPhone))
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .otherBank, .housingAndCommunalService:
                if let payeeCardNumber = operation.payeeCardNumber {
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(payeeCardNumber))
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .sfp:
                if var feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    feeViewModel.title = "Комиссия:"
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
            case .transport:
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
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
    
    enum PayeeViewModel {
        
        case singleRow(String)
        case doubleRow(String, String)
        case number(String, String, String, () -> Void)
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

        var title: String
        let amount: String
        
        internal init(title: String, amount: String) {
            self.title = title
            self.amount = amount
        }
        
        init?(with operation: OperationDetailData, currencyCode: String) {
            
            let feeAmount = operation.payerFee
            
            guard feeAmount >= 0 else {
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
        case purchase_return
        case processing
        
        //FIXME: localization required
        var name: String {
            
            switch self {
            case .reject: return "Отказ!"
            case .success: return "Успешно!"
            case .purchase_return: return "Возврат!"
            case .processing: return "В обработке"
            }
        }
        
        //FIXME: move to assets
        var colorHex: String {
            
            switch self {
            case .reject: return "#E3011B"
            case .success: return "#22C183"
            case .purchase_return: return "#22C183"
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

//MARK: - Samples

extension OperationDetailViewModel {
    
    static let sampleComplete: OperationDetailViewModel = {
        
        let productData = ProductData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: nil, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")])
        
        var viewModel = OperationDetailViewModel(productStatement: .init(mcc: nil, accountId: nil, accountNumber: "", amount: 20.0, cardTranNumber: nil, city: nil, comment: "Comment", country: nil, currencyCodeNumeric: 810, date: Date(), deviceCode: nil, documentAmount: 20.0, documentId: nil, fastPayment: nil, groupName: "Group Name", isCancellation: false, md5hash: "", merchantName: "Merchant Name", merchantNameRus: "Merchant Name Rus", opCode: nil, operationId: nil, operationType: OperationType.credit, paymentDetailType: .c2b, svgImage: .init(description: "Operation Group Sample"), terminalCode: nil, tranDate: Date(), type: .inside), product: productData, model: .emptyMock)!
        
        viewModel.header = HeaderViewModel(logo: viewModel.header.logo, status: .success, title: viewModel.header.title,  category: viewModel.header.category)
        
        viewModel.operation = OperationViewModel(bankLogo: Image(uiImage: UIImage(named: "Bank Logo Sample")!), payee: .doubleRow("payeeFullName", "payeeAccountNumber"), amount: .init(amount: 1000.25, currency: "RUB", operationType: .debit, payService: .applePay), fee: .init(title: "Комиссия:", amount: "50,00"), description: "Описание операции", date: viewModel.operation.date)
        
        viewModel.actionButtons = [ActionButtonViewModel(name: "Изменить", action: {}), ActionButtonViewModel(name: "Вернуть", action: {})]
        
        viewModel.featureButtons = [FeatureButtonViewModel(kind: .template(false), icon: "Operation Details Template", name: "+ Шаблон", action: {}), FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: {})]
        
        return viewModel
        
    }()
    
    static let sampleMin: OperationDetailViewModel = {
       
        let productData = ProductData(id: 10002585800, productType: .card, number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", accountNumber: "40817810000000000001", balance: 1000123, balanceRub: nil, currency: "RUB", mainField: "Gold", additionalField: "Зарплатная", customName: "Моя карта", productName: "VISA REWARDS R-5", openDate: nil, ownerId: 10001639855, branchId: 2000, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: "string"), largeDesign: .init(description: "string"), mediumDesign: .init(description: "string"), smallDesign: .init(description: "string"), fontDesignColor: .init(description: "FFFFFF"), background: [.init(description: "FFBB36")])
        
        var viewModel = OperationDetailViewModel(productStatement: .init(mcc: nil, accountId: nil, accountNumber: "", amount: 20.0, cardTranNumber: nil, city: nil, comment: "Comment", country: nil, currencyCodeNumeric: 810, date: Date(), deviceCode: nil, documentAmount: 20.0, documentId: nil, fastPayment: nil, groupName: "Group Name", isCancellation: false, md5hash: "", merchantName: "Merchant Name", merchantNameRus: "Merchant Name Rus", opCode: nil, operationId: nil, operationType: OperationType.credit, paymentDetailType: .c2b, svgImage: .init(description: "Operation Group Sample"), terminalCode: nil, tranDate: Date(), type: .inside), product: productData, model: .emptyMock)!
        
        viewModel.header = HeaderViewModel(logo: viewModel.header.logo, status: nil, title: viewModel.header.title,  category: nil)
        
        viewModel.operation = OperationViewModel(bankLogo: nil, payee: .singleRow("Иванов"), amount: .init(amount: 1000.25, currency: "RUB", operationType: .debit, payService: nil), fee: nil, description: nil, date: viewModel.operation.date)
        
        viewModel.actionButtons = nil
        
        viewModel.featureButtons = [FeatureButtonViewModel(kind: .template(true), icon: "Operation Details Template Selected", name: "Шаблон", action: {}), FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: {})]
        
        return viewModel
        
    }()
}

