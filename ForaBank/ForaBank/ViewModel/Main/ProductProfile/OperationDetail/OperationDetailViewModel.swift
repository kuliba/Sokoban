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
    @Published var templateButton: TemplateButtonView.ViewModel?
    @Published var isLoading: Bool
    @Published var sheet: Sheet?
    @Published var fullScreenSheet: FullScreenSheet?

    var templateAction: () -> Void = {}
    
    let model: Model
    private var bindings = Set<AnyCancellable>()
    private let animationDuration: Double = 0.5
    private let updateFastAll: UpdateFastAll
    private var paymentTemplateId: Int?
    
    init(
        productStatement: ProductStatementData,
        product: ProductData,
        updateFastAll: @escaping UpdateFastAll,
        model: Model
    ) {
                
        let header = HeaderViewModel(statement: productStatement, model: model)
        let operation = OperationViewModel(productStatement: productStatement, model: model)
        
        self.id = productStatement.id
        self.header = header
        self.operation = operation
        self.featureButtons = []
        self.templateButton = nil
        self.isLoading = false
        self.updateFastAll = updateFastAll
        self.model = model

        bind()

        if let infoFeatureButtonViewModel = infoFeatureButtonViewModel(with: productStatement, product: product) {
            
            self.featureButtons = [infoFeatureButtonViewModel]
        }
        
        if let documentId = productStatement.documentId {
            
            model.action.send(ModelAction.Operation.Detail.Request.documentId(documentId))
            
            withAnimation {
                
                self.isLoading = true
            }
        }
        
        self.updateFastAll()
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "OperationDetailViewModel initilazed")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "OperationDetailViewModel deinitilazed")
    }
    
    func bindTemplateButton(with button: TemplateButtonView.ViewModel) {
        
        templateButton?.action
            .compactMap({ $0 as? TemplateButtonView.ViewModel.ButtonAction })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                templateAction()
                
            }.store(in: &bindings)
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ModelAction.PaymentTemplate.Save.Complete:
                    
                    guard let statement = model.statement(statementId: id),
                          let documentId = statement.documentId else {
                        return
                    }
                    
                    model.action.send(ModelAction.Operation.Detail.Request.documentId(documentId))
                    
                case _ as ModelAction.PaymentTemplate.Delete.Complete:
                    
                    guard let statement = model.statement(statementId: id),
                          let documentId = statement.documentId else {
                        return
                    }
                    
                    model.action.send(ModelAction.Operation.Detail.Request.documentId(documentId))
                    
                case let payload as ModelAction.Operation.Detail.Response:
                    
                    withAnimation {
                        self.isLoading = false
                    }
                    switch payload.result {
                    case let .success(details: details):
                        guard let statement = model.statement(statementId: id),
                              let product = model.product(statementId: id) else {
                            return
                        }
                
                        self.update(with: statement, product: product, operationDetail: details)
                        
                        guard statement.paymentDetailType != .insideOther,
                              details.shouldHaveTemplateButton,
                              statement.shouldShowTemplateButton
                        else { return }
                        
                        self.templateButton = .init(
                            model: model,
                            state: .init(details: details),
                            operation: nil,
                            operationDetail: details
                        )
                        
                        if let templateButton = self.templateButton {
                                
                            bindTemplateButton(with: templateButton)
                        }
                        
                    case let .failure(error):
                        //MARK: Informer Detail Error
                        model.action.send(ModelAction.Informer.Show(informer: .init(message: "Ошибка получения данных", icon: .check)))
                        
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "ModelAction.Operation.Detail.Response action error: \(error)")
                    }
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        model.action
            .compactMap({ $0 as? ModelAction.PaymentTemplate.Delete.Failed })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] payload in
                //MARK: Informer Detail Error
                model.action.send(ModelAction.Informer.Show(informer: .init(message: "Не удалось удалить шаблон", icon: .check)))
                
            }).store(in: &bindings)
        
        model.action
            .compactMap({ $0 as? ModelAction.PaymentTemplate.Save.Failed })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] payload in
                //MARK: Informer Detail Error
                model.action.send(ModelAction.Informer.Show(informer: .init(message: "Не удалось добавить шаблон", icon: .check)))
                
            }).store(in: &bindings)
        
        model.action
            .compactMap { $0 as? ModelAction.Operation.Detail.ResponseWithEmptyData }
            .receive(on: DispatchQueue.main)
            .map { _ in false }
            .assign(to: &$isLoading)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as OperationDetailViewModelAction.ShowInfo:
                    if #available(iOS 14.5, *) {
                        sheet = .init(kind: .info(payload.viewModel))
                    }
                
                case let payload as OperationDetailViewModelAction.ShowDocument:
                    if #available(iOS 14.5, *) {
                        sheet = .init(kind: .printForm(payload.viewModel))
                    }
                    
                case let payload as OperationDetailViewModelAction.ShowChangeReturn:
                    let paymentsViewModel = PaymentsViewModel(source: payload.source, model: model) { [weak self] in
                        
                        self?.action.send(OperationDetailViewModelAction.CloseFullScreenSheet())
                    }
                    self.fullScreenSheet = .init(type: .payments(paymentsViewModel))

                case _ as OperationDetailViewModelAction.CloseSheet:
                    if #available(iOS 14.5, *) {
                        sheet = nil
                    }
                    
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
            
        case .betweenTheir, .insideBank, .externalIndivudual, .externalEntity, .housingAndCommunalService, .otherBank, .internet, .mobile, .direct, .sfp, .transport, .c2b, .insideDeposit, .insideOther, .taxes, .sberQRPayment:
            
            if productStatement.shouldShowDocumentButton, let documentButtonViewModel = self.documentButtonViewModel(with: operationDetail) {
                featureButtonsUpdated.append(documentButtonViewModel)
            }
            if let infoButtonViewModel = self.infoFeatureButtonViewModel(with: productStatement, product: product, operationDetail: operationDetail) {
                featureButtonsUpdated.append(infoButtonViewModel)
            }
            
        case .contactAddressless:
            // TODO: revert after templates fix
            // if let templateButtonViewModel = self.templateButtonViewModel(with: productStatement, operationDetail: operationDetail) {
            //     featureButtonsUpdated.append(templateButtonViewModel)
            // }
            if productStatement.shouldShowDocumentButton, let documentButtonViewModel = self.documentButtonViewModel(with: operationDetail) {
                featureButtonsUpdated.append(documentButtonViewModel)
            }
            if let infoButtonViewModel = self.infoFeatureButtonViewModel(with: productStatement, product: product, operationDetail: operationDetail) {
                featureButtonsUpdated.append(infoButtonViewModel)
            }
            if operationDetail.transferReference != nil {
                actionButtonsUpdated = self.actionButtons(with: operationDetail, statement: productStatement, product: product, dismissAction: { [weak self] in
                    self?.action.send(OperationDetailViewModelAction.CloseFullScreenSheet())
                })
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
        
        let viewModel: PrintFormView.ViewModel
    }
    
    struct ShowInfo: Action {
        
        let viewModel: OperationDetailInfoViewModel
    }
    
    struct ShowChangeReturn: Action {
     
        let source: Payments.Operation.Source
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
        
        return FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: { [weak self] in
            
            guard let self = self else {
                return
            }
            
            switch operationDetail.printFormType {
            case .closeAccount:
                let printFormViewModel = PrintFormView.ViewModel(type: .closeAccount(id: operationDetail.payerAccountId, paymentOperationDetailId: operationDetail.paymentOperationDetailId), model: self.model, dismissAction: {})
                
                self.action.send(OperationDetailViewModelAction.ShowDocument(viewModel: printFormViewModel))
                
            default:
                let printFormViewModel = PrintFormView.ViewModel(type: .operation(paymentOperationDetailId: paymentOperationDetailID, printFormType: printFormType), model: self.model)
                
                self.action.send(OperationDetailViewModelAction.ShowDocument(viewModel: printFormViewModel))
                
            }
        })
    }
    
    func actionButtons(with operationDetail: OperationDetailData, statement: ProductStatementData, product: ProductData, dismissAction: @escaping () -> Void) -> [ActionButtonViewModel] {
        
        var actionButtons = [ActionButtonViewModel]()

        let operationId = statement.operationId
        
        if let name = operationDetail.payeeFullName,
           let transferNumber = operationDetail.transferReference {
         
            let changeButton = ActionButtonViewModel(name: "Изменить",
                                                     action: { [weak self] in
                self?.action.send(OperationDetailViewModelAction.ShowChangeReturn(source: .change(operationId: operationId, transferNumber: transferNumber, name: name)))
            })
            
            actionButtons.append(changeButton)
        }

        let amountFormatted = model.amountFormatted(amount: operationDetail.amount, currencyCode: operationDetail.payerCurrency, style: .normal) ?? String(operationDetail.amount)

        if let transferNumber = operationDetail.transferReference {
            
            let returnButton = ActionButtonViewModel(name: "Вернуть",
                                                     action: { [weak self] in
                self?.action.send(OperationDetailViewModelAction.ShowChangeReturn(source: .return(operationId: operationDetail.paymentOperationDetailId, transferNumber: transferNumber, amount: amountFormatted, productId: product.id.description)))
            })
            
            actionButtons.append(returnButton)
        }
        
        return actionButtons
    }
}

//MARK: - Types

extension OperationDetailViewModel {
    
    typealias UpdateFastAll = () -> Void

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
            case .credit, .creditPlan, .creditFict:
                self.amount = "+" + (model.amountFormatted(amount: amount, currencyCodeNumeric: currencyCodeNumeric, style: .normal) ?? String(amount))
                
            case .debit, .debitPlan, .debitFict:
                self.amount = "-" + (model.amountFormatted(amount: amount, currencyCodeNumeric: currencyCodeNumeric, style: .normal) ?? String(amount))
                
            default:
                self.amount = ""
            }
            
            self.payService = payService
            self.colorHex = "1C1C1C"
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
            case .processing: return "В обработке!"
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
        let kind: Kind
        
        enum Kind {
            
            case info(OperationDetailInfoViewModel)
            case printForm(PrintFormView.ViewModel)
        }
        
        static func == (
            lhs: OperationDetailViewModel.Sheet,
            rhs: OperationDetailViewModel.Sheet
        ) -> Bool {
            
            lhs.id == rhs.id
        }
    }
    
    struct FullScreenSheet: Identifiable, Equatable {

        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case payments(PaymentsViewModel)
        }
        
        static func == (lhs: OperationDetailViewModel.FullScreenSheet, rhs: OperationDetailViewModel.FullScreenSheet) -> Bool {
            lhs.id == rhs.id
        }
    }
}

