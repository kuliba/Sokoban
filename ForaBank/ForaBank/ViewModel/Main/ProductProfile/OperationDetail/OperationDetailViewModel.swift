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
    
    let id: ProductStatementData.ID
    @Published var header: HeaderViewModel
    @Published var operation: OperationViewModel
    @Published var actionButtons: [ActionButtonViewModel]?
    @Published var featureButtons: [FeatureButtonViewModel]
    @Published var isLoading: Bool
    @Published var sheet: Sheet?
    @Published var fullScreenSheet: FullScreenSheet?

    private let model: Model
    private var bindings = Set<AnyCancellable>()
    private let animationDuration: Double = 0.5
    private var paymentTemplateId: Int?
    
    init(id: ProductStatementData.ID, header: HeaderViewModel, operation: OperationViewModel, actionButtons: [ActionButtonViewModel]?, featureButtons: [FeatureButtonViewModel], isLoading: Bool, model: Model = .emptyMock) {
        
        self.id = id
        self.header = header
        self.operation = operation
        self.actionButtons = actionButtons
        self.featureButtons = featureButtons
        self.isLoading = isLoading
        self.model = model
    }
    
    init?(productStatement: ProductStatementData, product: ProductData, model: Model) {
        
        guard productStatement.paymentDetailType != .notFinance else {
            return nil
        }
        
        self.id = productStatement.id
        self.header = .init(statement: productStatement, model: model)
        self.operation = .init(productStatement: productStatement, model: model)
        self.actionButtons = nil
        self.featureButtons = []
        self.isLoading = false
        self.model = model
        
        if let infoFeatureButtonViewModel = infoFeatureButtonViewModel(with: productStatement, product: product) {
            
            self.featureButtons = [infoFeatureButtonViewModel]
        }
        
        bind()
        
        if let documentId = productStatement.documentId {
            
            model.action.send(ModelAction.Payment.OperationDetail.Request(documentId: "\(documentId)"))
            
            withAnimation {
                self.isLoading = true
            }
        }
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ModelAction.PaymentTemplate.Save.Complete:
                    guard let statement = model.statement(statementId: id) else {
                        return
                    }
                    
                    if let documentId = statement.documentId {
                        
                        model.action.send(ModelAction.Payment.OperationDetail.Request(documentId: "\(documentId)"))
                        
                    }
                    
                case _ as ModelAction.PaymentTemplate.Delete.Complete:
                    
                    guard let statement = model.statement(statementId: id) else {
                        return
                    }
                    
                    if let documentId = statement.documentId {
                        
                        model.action.send(ModelAction.Payment.OperationDetail.Request(documentId: "\(documentId)"))
                        
                    }
                    
                case let result as ModelAction.Payment.OperationDetail.Response:
                    withAnimation {
                        self.isLoading = false
                    }
                    switch result {
                    case .success(details: let details):
                        guard let statement = model.statement(statementId: id),
                                let product = model.product(statementId: id) else {
                            return
                        }
                        
                        self.update(with: statement, product: product, operationDetail: details)
                        
                    default:
                        break
               
                    }
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as OperationDetailViewModelAction.ShowInfo:
                    sheet = .init(type: .info(payload.viewModel))
                
                case let payload as OperationDetailViewModelAction.ShowDocument:
                    let printFormViewModel = PrintFormView.ViewModel(type: .operation(paymentOperationDetailId: payload.paymentOperationDetailID, printFormType: payload.printFormType), model: model)
                    sheet = .init(type: .printForm(printFormViewModel))
                    
                case let payload as OperationDetailViewModelAction.ShowChangeReturn:
                    fullScreenSheet = .init(type: .changeReturn(payload.viewModel))
                    
                case _ as OperationDetailViewModelAction.CloseSheet:
                    sheet = nil
                    
                case _ as OperationDetailViewModelAction.CloseFullScreenSheet:
                    fullScreenSheet = nil
                    
                case let payload as OperationDetailViewModelAction.CopyNumber:
                    UIPasteboard.general.string = payload.number

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func update(with productStatement: ProductStatementData, product: ProductData, operationDetail: OperationDetailData?) {
        
        guard let operationDetail = operationDetail else {
            return
        }
        
        withAnimation {
            
            operation = operation.updated(with: productStatement, operation: operationDetail, viewModel: self)
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
                actionButtonsUpdated = self.actionButtons(with: operationDetail, statement: productStatement, product: product, dismissAction: {[weak self] in self?.action.send(OperationDetailViewModelAction.CloseFullScreenSheet())})
            }
            
        default:
            break
        }
        
        withAnimation {
            
            self.actionButtons = actionButtonsUpdated
            self.featureButtons = featureButtonsUpdated
        }
    }
}

//MARK: - Action

enum OperationDetailViewModelAction {

    struct Dismiss: Action {}
    
    struct ShowDocument: Action {
        
        let paymentOperationDetailID: Int
        let printFormType: PrintFormType
    }
    
    struct ShowInfo: Action {
        
        let viewModel: OperationDetailInfoViewModel
    }
    
    struct ShowChangeReturn: Action {
     
        let viewModel: ChangeReturnViewModel
    }
    
    struct CopyNumber: Action {
        
        let number: String
    }
    
    struct CloseSheet: Action {}
    
    struct CloseFullScreenSheet: Action {}
}

//MARK: - Private helpers

private extension OperationDetailViewModel {
    
    func infoFeatureButtonViewModel(with productStatement: ProductStatementData, product: ProductData, operationDetail: OperationDetailData? = nil) -> FeatureButtonViewModel? {
        
        guard let operationDetailInfoViewModel = OperationDetailInfoViewModel(with: productStatement, operation: operationDetail, product: product, dismissAction: { [weak self] in self?.action.send(OperationDetailViewModelAction.CloseSheet())}, model: model) else {
            return nil
        }
        
    return FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: { [weak self] in self?.action.send(OperationDetailViewModelAction.ShowInfo(viewModel: operationDetailInfoViewModel)) })
    }
    
    func documentButtonViewModel(with operationDetail: OperationDetailData) -> FeatureButtonViewModel? {
        
        let paymentOperationDetailID = operationDetail.paymentOperationDetailId
        let printFormType = operationDetail.printFormType
        
        return FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: { [weak self] in self?.action.send(OperationDetailViewModelAction.ShowDocument(paymentOperationDetailID: paymentOperationDetailID, printFormType: printFormType))})
    }
    
    func templateButtonViewModel(with productStatement: ProductStatementData, operationDetail: OperationDetailData) -> FeatureButtonViewModel? {
        
        // check if template allowed for this operation type
        guard model.paymentTemplatesAllowed.contains(productStatement.paymentDetailType) else {
            return nil
        }
        
        if let paymentTemplateId = operationDetail.paymentTemplateId {
                
                let action = ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [paymentTemplateId])
                return FeatureButtonViewModel(kind: .template(true), icon: "Operation Details Template Selected", name: "Шаблон", action: { [weak self] in self?.model.action.send(action)})
            
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
            return productStatement.merchant
            
        case .mobile :
            return operationDetail.payeePhone
            
        case .externalIndivudual, .externalEntity:
            return operationDetail.payeeFullName
            
        case .otherBank:
            return operationDetail.payeeCardNumber
            
        case .transport:
            return productStatement.merchantNameRus
            
        default:
            return nil
        }
    }
    
    func actionButtons(with operationDetail: OperationDetailData, statement: ProductStatementData, product: ProductData, dismissAction: @escaping () -> Void) -> [ActionButtonViewModel] {
        
        var actionButtons = [ActionButtonViewModel]()
        
        let amountFormatted = model.amountFormatted(amount: operationDetail.amount, currencyCode: operationDetail.currencyAmount, style: .normal) ?? String(operationDetail.amount)
        
        let paymentSystemImage = statement.md5hash
        
        let changeViewModel = ChangeReturnViewModel(
            amount: amountFormatted,
            name: operationDetail.payeeFirstName ?? "",
            surname: operationDetail.payeeSurName ?? "",
            secondName: operationDetail.payeeMiddleName ?? "",
            paymentOperationDetailId: operationDetail.paymentOperationDetailId,
            transferReference: operationDetail.transferReference ?? "",
            product: product,
            paymantSystemIcon: paymentSystemImage,
            type: .changePay,
            operatorsViewModel: .init(closeAction: dismissAction, template: nil))
        
        let changeButton = ActionButtonViewModel(name: "Изменить",
                                                 action: { [weak self] in
            self?.action.send(OperationDetailViewModelAction.ShowChangeReturn(viewModel: changeViewModel))
        })
        actionButtons.append(changeButton)
        
        
        let returnViewModel = ChangeReturnViewModel(
            amount: amountFormatted,
            name: operationDetail.payeeFirstName ?? "",
            surname: operationDetail.payeeSurName ?? "",
            secondName: operationDetail.payeeMiddleName ?? "",
            paymentOperationDetailId: operationDetail.paymentOperationDetailId,
            transferReference: operationDetail.transferReference ?? "",
            product: product,
            paymantSystemIcon: paymentSystemImage,
            type: .returnPay,
            operatorsViewModel: .init(closeAction: dismissAction, template: nil))
        let returnButton = ActionButtonViewModel(name: "Вернуть",
                                                 action: { [weak self] in
            self?.action.send(OperationDetailViewModelAction.ShowChangeReturn(viewModel: returnViewModel))
        })
        actionButtons.append(returnButton)
        
        return actionButtons
    }
}

//MARK: - Types

extension OperationDetailViewModel {

    enum PayeeViewModel {
        
        case singleRow(String)
        case doubleRow(String, String)
        case number(String, String, String, () -> Void)
    }
    
    struct AmountViewModel {
 
        let amount: String
        let payService: PayServiceViewModel?
        let colorHex: String
        
        internal init(amount: String, payService: OperationDetailViewModel.PayServiceViewModel?, colorHex: String) {
           
            self.amount = amount
            self.payService = payService
            self.colorHex = colorHex
        }
        
        init(amount: Double, currencyCodeNumeric: Int, operationType: OperationType, payService: PayServiceViewModel?, model: Model) {
            
            switch operationType {
            case .credit:
                self.amount = "+" + (model.amountFormatted(amount: amount, currencyCodeNumeric: currencyCodeNumeric, style: .normal) ?? String(amount))
                self.colorHex = "1C1C1C"
                
            case .debit:
                self.amount = "-" + (model.amountFormatted(amount: amount, currencyCodeNumeric: currencyCodeNumeric, style: .normal) ?? String(amount))
                self.colorHex = "1C1C1C"
                
            default:
                self.amount = ""
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
    
    struct Sheet: Identifiable, Equatable {

        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case info(OperationDetailInfoViewModel)
            case printForm(PrintFormView.ViewModel)
        }
        
        static func == (lhs: OperationDetailViewModel.Sheet, rhs: OperationDetailViewModel.Sheet) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    struct FullScreenSheet: Identifiable, Equatable {

        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case changeReturn(ChangeReturnViewModel)
        }
        
        static func == (lhs: OperationDetailViewModel.FullScreenSheet, rhs: OperationDetailViewModel.FullScreenSheet) -> Bool {
            lhs.id == rhs.id
        }
    }
}

