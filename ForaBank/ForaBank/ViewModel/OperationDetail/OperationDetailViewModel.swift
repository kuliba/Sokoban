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
    
    private let animationDuration: Double = 0.5
    
    init?(paymentDetailType: PaymentDetailType, documentId: Int?, svgImage: Image, merchantName: String, groupName: String, mcc: Int, amount: Double, currencyCode: String, tranDate: Date, foreignPhoneNumber: String?, documentComment: String?, operationType: OperationType, product: UserAllCardsModel) {
        
        switch paymentDetailType {
        case .betweenTheir, .insideBank, .otherBank:
            self.header = HeaderViewModel(logo: svgImage, status: nil, title: groupName, category: "Переводы")
            let payeeViewModel: PayeeViewModel = .singleRow(merchantName)
            let amountViewModel = AmountViewModel(amount: amount, currency: currencyCode, operationType: operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDate)
            
        case .contactAddressless, .direct:
            self.header = HeaderViewModel(logo: svgImage, status: nil, title: groupName, category: nil)
            let payeeViewModel: PayeeViewModel = .singleRow(merchantName)
            let amountViewModel = AmountViewModel(amount: amount, currency: currencyCode, operationType: operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDate)
            
        case .externalIndivudual, .externalEntity:
            self.header = HeaderViewModel(logo: svgImage, status: nil, title: groupName, category: nil)
            let amountViewModel = AmountViewModel(amount: amount, currency: currencyCode, operationType: operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDate)
            
            
        case .housingAndCommunalService, .insideOther, .internet, .mobile:
            self.header = HeaderViewModel(logo: svgImage, status: nil, title: merchantName, category: "\(groupName)")
            let amountViewModel = AmountViewModel(amount: amount, currency: currencyCode, operationType: operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDate)
            
        case .notFinance:
            return nil

        case .outsideCash:
            self.header = HeaderViewModel(logo: svgImage, status: nil, title: groupName, category: "Прочие")
            let payeeViewModel: PayeeViewModel = .singleRow(merchantName)
            let amountViewModel = AmountViewModel(amount: amount, currency: currencyCode, operationType: operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDate)
            
        case .outsideOther:
            self.header = HeaderViewModel(logo: svgImage, status: nil, title: merchantName, category: "\(groupName) (\(mcc))")
            let amountViewModel = AmountViewModel(amount: amount, currency: currencyCode, operationType: operationType, payService: nil)
            self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: tranDate)
            
        case .sfp:
            let sfpLogoImage = Image("Operation Type Contact Icon")
            self.header = HeaderViewModel(logo: sfpLogoImage, status: nil, title: groupName, category: nil)
            var payeeViewModel: PayeeViewModel
            
            //FIXME: mask phone number
            if let foreignPhoneNumber = foreignPhoneNumber?.replacingOccurrences(of: " ", with: "") {
                
                payeeViewModel = .doubleRow(merchantName, foreignPhoneNumber)
                
            } else {
                
                payeeViewModel = .singleRow(merchantName)
            }
            let amountViewModel = AmountViewModel(amount: amount, currency: currencyCode, operationType: operationType, payService: nil)
            if let documentComment = documentComment, documentComment != "" {
                
                self.operation = OperationViewModel(bankLogo: svgImage, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: documentComment, date: tranDate)
           
            } else {
                
                self.operation = OperationViewModel(bankLogo: svgImage, payee: payeeViewModel, amount: amountViewModel, fee: nil, description: nil, date: tranDate)
            }
        }
        
        self.actionButtons = nil
        self.featureButtons = []
        self.isLoading = true
        
        fetchOperationDetail(documentId: documentId, paymentDetailType: paymentDetailType, groupName: groupName, merchantName: merchantName, currencyCode: currencyCode, operationType: operationType, product: product)
    }
    
    func fetchOperationDetail(documentId: Int?, paymentDetailType: PaymentDetailType, groupName: String, merchantName: String, currencyCode: String, operationType: OperationType, product: UserAllCardsModel) {
        
        guard let documentId = documentId else {
            
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
            
            guard error == nil, let model = model, model.statusCode == 0, let operationDetailModel = model.data else {
                return
            }
            
            DispatchQueue.main.async {
                
                //FIXME: refactor more elegant way without self
                withAnimation(.easeInOut(duration: self.animationDuration)) {
                    
                    self.operation = self.operation.updated(with: operationDetailModel, paymentDetailType: paymentDetailType, merchantName: merchantName, currencyCode: currencyCode, viewModel: self)
                }
                
                if groupName == "Перевод Contact" && operationType == .debit {
                    var actionButtons = [ActionButtonViewModel]()
                    
                    let changeButton = ActionButtonViewModel(name: "Изменить",
                                                             action: { [weak self] in
                        self?.action.send(OperationDetailViewModelAction.Change(
                            amount: (operationDetailModel.amount ?? 0).currencyFormatter(symbol: operationDetailModel.currencyAmount ?? ""),
                            name: operationDetailModel.payeeFirstName ?? "",
                            surname: operationDetailModel.payeeSurName ?? "",
                            secondName: operationDetailModel.payeeMiddleName ?? "",
                            paymentOperationDetailId: operationDetailModel.paymentOperationDetailID ?? 0,
                            transferReference: operationDetailModel.transferReference ?? "",
                            product: product)
                        )
                    })
                    actionButtons.append(changeButton)
                    
                    let returnButton = ActionButtonViewModel(name: "Вернуть",
                                                             action: { [weak self] in
                        self?.action.send(OperationDetailViewModelAction.Return(
                            amount: (operationDetailModel.amount ?? 0).currencyFormatter(symbol: operationDetailModel.currencyAmount ?? ""),
                            fullName: operationDetailModel.payeeFullName ?? "",
                            name: operationDetailModel.payeeFirstName ?? "",
                            surname: operationDetailModel.payeeSurName ?? "",
                            secondName: operationDetailModel.payeeMiddleName ?? "",
                            paymentOperationDetailId: operationDetailModel.paymentOperationDetailID ?? 0,
                            transferReference: operationDetailModel.transferReference ?? "",
                            product: product)
                        )
                    })
                    actionButtons.append(returnButton)
                    
                    withAnimation(.easeInOut(duration: self.animationDuration)) {
                        
                        self.actionButtons = actionButtons
                    }
                }
                
                // check if transferReferensen is not nill
                if let paymentOperationDetailID = operationDetailModel.paymentOperationDetailID {

                    // detail button
                    if let printFormType = operationDetailModel.printFormType {
                        
                        let detailButtonViewModel = FeatureButtonViewModel(icon: "Operation Details Document", name: "Документ", action: { [weak self] in self?.action.send(OperationDetailViewModelAction.ShowDocument(paymentOperationDetailID: paymentOperationDetailID, printFormType: printFormType))})
                        
                        withAnimation(.easeInOut(duration: self.animationDuration)) {
                            
                            self.featureButtons.append(detailButtonViewModel)
                        }
                    }
                    
                    //TODO: temp disabled
                    /*
                    // info button
                    if let detailViewModel = ConfirmViewControllerModel(operation: operationDetailModel) {
                        
                        let documentButtonViewModel = FeatureButtonViewModel(icon: "Operation Details Info", name: "Детали", action: { [weak self] in self?.action.send(OperationDetailViewModelAction.ShowDetail(viewModel: detailViewModel))})
                        self.featureButtons.append(documentButtonViewModel)
                    }
                     
                     */
                }
            }
        }
    }
}

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
        
        func updated(with operation: OperationDetailDatum, paymentDetailType: PaymentDetailType, merchantName: String, currencyCode: String, viewModel: OperationDetailViewModel) -> OperationViewModel {
            
            var operationViewModel = self
            
            switch paymentDetailType {
            case .contactAddressless:
                if let transferReference = operation.transferReference {

                    let payeeViewModel: PayeeViewModel = .number(merchantName, transferReference, {[weak viewModel] in viewModel?.action.send(OperationDetailViewModelAction.CopyNumber(number: transferReference)) })
                    
                    operationViewModel = operationViewModel.updated(with: payeeViewModel)
                }
                
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
                    operationViewModel = operationViewModel.updated(with: feeViewModel)
                }
                
            case .direct:
                if let memberId = operation.memberID,
                   let bank = Dict.shared.banks?.first(where: { $0.memberID == memberId }),
                   let bankLogoSVG = bank.svgImage {
                    
                    let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                    operationViewModel = operationViewModel.updated(with: bankLogoImage)
                }
                
                //FIXME: mask phone number
                if let payeePhone = operation.payeePhone {
                    
                    operationViewModel = operationViewModel.updated(with: .doubleRow(merchantName, payeePhone))
                }

            case .externalIndivudual, .externalEntity:

                if let bankName = operation.payeeBankName,
                   let bank = Dict.shared.banks?.first(where: { $0.memberNameRus == bankName }),
                   let bankLogoSVG = bank.svgImage {
                    
                    let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                    operationViewModel = operationViewModel.updated(with: bankLogoImage)
                }
                
                if let payeeFullName = operation.payeeFullName, let payeeAccountNumber = operation.payerAccountNumber {
                    
                    operationViewModel = operationViewModel.updated(with: .doubleRow(payeeFullName, payeeAccountNumber))
                }
                
            case .internet:
                if let account = operation.account {
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(account))
                }
                
            case .mobile:
                if let payeePhone = operation.payeePhone {
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(payeePhone))
                }
                
            case .otherBank, .housingAndCommunalService:
                if let payeeCardNumber = operation.payeeCardNumber {
                    
                    operationViewModel = operationViewModel.updated(with: .singleRow(payeeCardNumber))
                }
                
            case .sfp:
                if let feeViewModel = FeeViewModel(with: operation, currencyCode: currencyCode)  {
                    
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
            self.title = "Комиссия:"
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
    
    struct ActionButtonViewModel: Hashable {
        
        let name: String
        let action: () -> Void
        
        static func == (lhs: ActionButtonViewModel, rhs: ActionButtonViewModel) -> Bool {
            
            lhs.name == rhs.name
        }
        
        func hash(into hasher: inout Hasher) {

            hasher.combine(name)
        }
    }
    
    struct FeatureButtonViewModel: Hashable {

        let icon: String
        let name: String
        let action: () -> Void
        
        static func == (lhs: FeatureButtonViewModel, rhs: FeatureButtonViewModel) -> Bool {
            
            lhs.icon == rhs.icon && lhs.name == rhs.name
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(icon)
            hasher.combine(name)
        }
    }
}

//MARK: - convenience inits

extension OperationDetailViewModel {
    
    convenience init?(with model: GetDepositStatementDatum, currency: String, product: UserAllCardsModel) {
        
        guard let paymentDetailType = model.paymentDetailType,
        let svgImageData = model.svgImage,
        let groupName = model.groupName,
        let amount = model.amount else {
            return nil
        }
        
        let documentId = model.documentID
        let svgImage = Image(uiImage: svgImageData.convertSVGStringToImage())
        let merchantName = (model.merchantNameRus ?? model.merchantName) ?? ""
        let mcc = model.mcc ?? 0
        let tranDate = model.transactionDate
        let foreignPhoneNumber = model.fastPayment?.foreignPhoneNumber
        let documentComment = model.fastPayment?.documentComment
        let operationType = model.operationTypeEnum
        
        self.init(paymentDetailType: paymentDetailType, documentId: documentId, svgImage: svgImage, merchantName: merchantName, groupName: groupName, mcc: mcc, amount: amount, currencyCode: currency, tranDate: tranDate, foreignPhoneNumber: foreignPhoneNumber, documentComment: documentComment, operationType: operationType, product: product)
    }
    
    convenience init?(with model: GetCardStatementDatum, currency: String, product: UserAllCardsModel) {
        
        guard let paymentDetailType = model.paymentDetailType,
        let svgImageData = model.svgImage,
        let groupName = model.groupName,
        let amount = model.amount else {
            return nil
        }
        
        let documentId = model.documentID
        let svgImage = Image(uiImage: svgImageData.convertSVGStringToImage())
        let merchantName = (model.merchantNameRus ?? model.merchantName) ?? ""
        let mcc = model.mcc ?? 0
        let tranDate = model.transactionDate
        let foreignPhoneNumber = model.fastPayment?.foreignPhoneNumber
        let documentComment = model.fastPayment?.documentComment
        let operationType = model.operationTypeEnum
        
        self.init(paymentDetailType: paymentDetailType, documentId: documentId, svgImage: svgImage, merchantName: merchantName, groupName: groupName, mcc: mcc, amount: amount, currencyCode: currency, tranDate: tranDate, foreignPhoneNumber: foreignPhoneNumber, documentComment: documentComment, operationType: operationType, product: product)
    }
    
    convenience init?(with model: GetAccountStatementDatum, currency: String, product: UserAllCardsModel) {
        
        guard let paymentDetailType = model.paymentDetailType,
        let svgImageData = model.svgImage,
        let groupName = model.groupName,
        let amount = model.amount else {
            return nil
        }
        
        let documentId = model.documentID
        let svgImage = Image(uiImage: svgImageData.convertSVGStringToImage())
        let merchantName = (model.merchantNameRus ?? model.merchantName) ?? ""
        let mcc = model.mcc ?? 0
        let tranDate = model.transactionDate
        let foreignPhoneNumber = model.fastPayment?.foreignPhoneNumber
        let documentComment = model.fastPayment?.documentComment
        let operationType = model.operationTypeEnum
        
        self.init(paymentDetailType: paymentDetailType, documentId: documentId, svgImage: svgImage, merchantName: merchantName, groupName: groupName, mcc: mcc, amount: amount, currencyCode: currency, tranDate: tranDate, foreignPhoneNumber: foreignPhoneNumber, documentComment: documentComment, operationType: operationType, product: product)
    }
}

extension OperationDetailViewModel {
    
    static let sampleComplete: OperationDetailViewModel = {
        
        var viewModel = OperationDetailViewModel(paymentDetailType: .sfp, documentId: 0, svgImage: Image(uiImage: UIImage(named: "Operation Group Sample")!), merchantName: "Merchant Name", groupName: "Group Name", mcc: 234, amount: 1234, currencyCode: "RUS", tranDate: Date(), foreignPhoneNumber: nil, documentComment: nil, operationType: .debit, product: UserAllCardsModel())!
        
        viewModel.header = HeaderViewModel(logo: viewModel.header.logo, status: .success, title: viewModel.header.title,  category: viewModel.header.category)
        
        viewModel.operation = OperationViewModel(bankLogo: Image(uiImage: UIImage(named: "Bank Logo Sample")!), payee: .number("Иванов Иван Иванович", "4556676767", {}), amount: .init(amount: 1000.25, currency: "RUB", operationType: .debit, payService: .applePay), fee: .init(title: "Комиссия:", amount: "50,00"), description: "Описание операции", date: viewModel.operation.date)
        
        viewModel.actionButtons = [ActionButtonViewModel(name: "Изменить", action: {}), ActionButtonViewModel(name: "Вернуть", action: {})]
        
        viewModel.featureButtons = [FeatureButtonViewModel(icon: "Operation Details Template", name: "+ Шаблон", action: {}), FeatureButtonViewModel(icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(icon: "Operation Details Info", name: "Детали", action: {})]
        
        return viewModel
        
    }()
    
    static let sampleMin: OperationDetailViewModel = {
       
        var viewModel = OperationDetailViewModel(paymentDetailType: .sfp, documentId: 0, svgImage: Image(uiImage: UIImage(named: "Operation Group Sample")!), merchantName: "Merchant Name", groupName: "Group Name", mcc: 234, amount: 1234, currencyCode: "RUS", tranDate: Date(), foreignPhoneNumber: nil, documentComment: nil, operationType: .debit, product: UserAllCardsModel())!
        
        viewModel.header = HeaderViewModel(logo: viewModel.header.logo, status: nil, title: viewModel.header.title,  category: nil)
        
        viewModel.operation = OperationViewModel(bankLogo: nil, payee: .singleRow("Иванов"), amount: .init(amount: 1000.25, currency: "RUB", operationType: .debit, payService: nil), fee: nil, description: nil, date: viewModel.operation.date)
        
        viewModel.actionButtons = nil
        
        viewModel.featureButtons = [FeatureButtonViewModel(icon: "Operation Details Template", name: "+ Шаблон", action: {}), FeatureButtonViewModel(icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(icon: "Operation Details Info", name: "Детали", action: {})]
        
        return viewModel
        
    }()
}
