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
    
    @Published var group: GroupViewModel
    @Published var operation: OperationViewModel
    @Published var actionButtons: [ActionButtonViewModel]?
    @Published var featureButtons: [FeatureButtonViewModel]
    
    lazy var dismissAction: () -> Void = {[weak self] in
        self?.action.send(OperationDetailViewModelAction.Dismiss())
    }
    
    private let groupName: String
    private let operationType: OperationType
    private let data: OperationDetailDatum?
    private let product: UserAllCardsModel
    
    init(documentId: Int, groupImage: UIImage, merchantName: String, groupName: String, amount: Double, currency: String, operationType: OperationType, date: Date, product: UserAllCardsModel) {
        
        self.group = GroupViewModel(logo: Image(uiImage: groupImage), merchant: merchantName, status: nil, name: groupName)
        let amountViewModel = AmountViewModel(amount: amount, currency: currency, operationType: operationType, payService: nil)
        self.operation = OperationViewModel(bankLogo: nil, payee: nil, amount: amountViewModel, fee: nil, description: nil, date: date)
        self.actionButtons = nil
        self.featureButtons = []
        
        self.groupName = groupName
        self.operationType = operationType
        self.data = nil
        self.product = product
        
        fetchOperationDetail(documentId: documentId)
    }
    
    func fetchOperationDetail(documentId: Int) {
        
        let body = [ "documentId" : documentId] as [String : AnyObject]
        
        NetworkManager<GetOperationDetailDecodebleModel>.addRequest(.getOperationDetail, [:], body) { [weak self] model, error in
            
            guard let self = self else {
                return
            }
            guard error == nil, let model = model, model.statusCode == 0, let operationDetailModel = model.data else {
                return
            }
            
            DispatchQueue.main.async {
                
                //FIXME: refactor more elegant way without self
                self.operation = self.operation.updated(with: operationDetailModel, viewModel: self)
                
                if self.groupName == "Перевод Contact" && self.operationType == .debit {
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
                            product: self?.product ?? UserAllCardsModel())
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
                            product: self?.product ?? UserAllCardsModel())
                        )
                    })
                    actionButtons.append(returnButton)
                    
                    self.actionButtons = actionButtons
                }
                
                // check if transferReferensen is not nill
                if let paymentOperationDetailID = operationDetailModel.paymentOperationDetailID {

                    // detail button
                    if let printFormType = operationDetailModel.printFormType {
                        
                        let detailButtonViewModel = FeatureButtonViewModel(icon: "Operation Details Document", name: "Документ", action: { [weak self] in self?.action.send(OperationDetailViewModelAction.ShowDocument(paymentOperationDetailID: paymentOperationDetailID, printFormType: printFormType))})
                        self.featureButtons.append(detailButtonViewModel)
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
    
    struct GroupViewModel {
        
        let logo: Image
        let merchant: String
        let status: StatusViewModel?
        let name: String?
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
        
        func updated(with operation: OperationDetailDatum, viewModel: OperationDetailViewModel) -> OperationViewModel {
            
            var operationViewModel = self
            
            if let updatedDate = operation.dateForDetail {
                
                operationViewModel = operationViewModel.updated(with: updatedDate)
            }
            
            if let payeeVewModel = PayeeViewModel(with: operation, viewModel: viewModel) {
                
                operationViewModel = operationViewModel.updated(with: payeeVewModel)
            }
            
            if let feeViewModel = FeeViewModel(with: operation)  {
                
                operationViewModel = operationViewModel.updated(with: feeViewModel)
            }
            
            // bank logo icon
            if let bankName = operation.payeeBankName,
               let bank = Dict.shared.banks?.first(where: { $0.memberNameRus == bankName }),
               let bankLogoSVG = bank.svgImage {
                
                let bankLogoImage = Image(uiImage: bankLogoSVG.convertSVGStringToImage())
                operationViewModel = operationViewModel.updated(with: bankLogoImage)
            }
            
            return operationViewModel
        }
    }
    
    enum PayeeViewModel {
        
        case singleRow(String)
        case doubleRow(String, String)
        case number(String, String, () -> Void)
        
        init?(with operation: OperationDetailDatum, viewModel: OperationDetailViewModel) {
            
            guard let name = operation.payerFullName else {
                return nil
            }
            
            if let transferNumber = operation.transferReference {

                self = .number(name, transferNumber, {[weak viewModel] in viewModel?.action.send(OperationDetailViewModelAction.CopyNumber(number: transferNumber)) })
                
            } else {
                
                if let phone = operation.payeePhone {
                    
                    let mask = StringMask(mask: "+7 (000) 000-00-00")
                    let maskPhone = mask.mask(string: phone) ?? phone
                    self = .doubleRow(name, maskPhone)
                    
                } else if let cardNumber = operation.payeeCardNumber {
                    
                    self = .doubleRow(name, cardNumber)
                    
                } else {
                    
                    self = .singleRow(name)
                }
            }
        }
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
        
        init?(with operation: OperationDetailDatum) {
            
            guard let feeAmount = operation.payerFee,
            let feeAmountFormatted = NumberFormatter.fee.string(from: NSNumber(value: feeAmount)) else {
                return nil
            }
            
            //FIXME: localization required
            self.title = "Комиссия:"
            self.amount = feeAmountFormatted
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
    
    convenience init(with model: GetDepositStatementDatum, currency: String, product: UserAllCardsModel) {
        
        let documentId = model.documentID ?? 0
        let groupImage = model.svgImage?.convertSVGStringToImage() ?? UIImage()
        let merchantName = model.merchantNameRus ?? "[merchant name]"
        let categoryName = model.groupName ?? "[category name]"
        let amount = Double(model.amount ?? 0)
        let operationType = model.operationTypeEnum
        let date = model.transactionDate
        
        self.init(documentId: documentId, groupImage: groupImage, merchantName: merchantName, groupName: categoryName, amount: amount, currency: currency, operationType: operationType, date: date, product: product)
    }
    
    convenience init(with model: GetCardStatementDatum, currency: String, product: UserAllCardsModel) {
        
        let documentId = model.documentID ?? 0
        let groupImage = model.svgImage?.convertSVGStringToImage() ?? UIImage()
        let merchantName = model.merchantNameRus ?? "[merchant name]"
        let categoryName = model.groupName ?? "[category name]"
        let amount = Double(model.amount ?? 0)
        let operationType = model.operationTypeEnum
        let date = model.transactionDate
        
        self.init(documentId: documentId, groupImage: groupImage, merchantName: merchantName, groupName: categoryName, amount: amount, currency: currency, operationType: operationType, date: date, product: product)
    }
    
    convenience init(with model: GetAccountStatementDatum, currency: String, product: UserAllCardsModel) {
        
        let documentId = model.documentID ?? 0
        let groupImage = model.svgImage?.convertSVGStringToImage() ?? UIImage()
        let merchantName = model.merchantNameRus ?? "[merchant name]"
        let categoryName = model.groupName ?? "[category name]"
        let amount = Double(model.amount ?? 0)
        let operationType = model.operationTypeEnum
        let date = model.transactionDate
        
        self.init(documentId: documentId, groupImage: groupImage, merchantName: merchantName, groupName: categoryName, amount: amount, currency: currency, operationType: operationType, date: date, product: product)
    }
}

extension OperationDetailViewModel {
    
    static let sample: OperationDetailViewModel = {
       
        var viewModel = OperationDetailViewModel(documentId: 0, groupImage: UIImage(named: "Operation Group Sample")!, merchantName: "Merchant name", groupName: "Category name", amount: 1000.25, currency: "RUB", operationType: .debit, date: Date(), product:  UserAllCardsModel())
        
        viewModel.group = GroupViewModel(logo: viewModel.group.logo, merchant: viewModel.group.merchant, status: .success, name: viewModel.group.name)
        
        viewModel.operation = OperationViewModel(bankLogo: Image(uiImage: UIImage(named: "Bank Logo Sample")!), payee: .number("Иванов Иван Иванович", "4556676767", {}), amount: .init(amount: 1000.25, currency: "RUB", operationType: .debit, payService: .applePay), fee: .init(title: "Комиссия:", amount: "50,00"), description: "Описание операции", date: viewModel.operation.date)
        
        viewModel.actionButtons = [ActionButtonViewModel(name: "Изменить", action: {}), ActionButtonViewModel(name: "Вернуть", action: {})]
        
        viewModel.featureButtons = [FeatureButtonViewModel(icon: "Operation Details Template", name: "+ Шаблон", action: {}), FeatureButtonViewModel(icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(icon: "Operation Details Info", name: "Детали", action: {})]
        
        return viewModel
        
    }()
}
