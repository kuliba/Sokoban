//
//  PaymentsSuccessViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI
import Combine

class PaymentsSuccessViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var optionButtons: [PaymentsSuccessOptionButtonViewModel]
    @Published var repeatButton: ButtonSimpleView.ViewModel?
    @Published var actionButton: ButtonSimpleView.ViewModel
    @Published var additionalButtons: [AdditionalButton]?
    @Published var sheet: Sheet?
    @Published var isLinkActive: Bool = false
    @Published var fullScreenSheet: FullScreenSheet?
    @Published var alert: Alert.ViewModel?
    @Published var transferNumber: TransferNumber?
    @Published var templateButton: TemplateButtonView.ViewModel?
    
    var refreshTemplateButton = false
    
    var amount: String?
    var logo: LogoIconViewModel?
    
    let id = UUID()
    let title: String?
    let warningTitle: String?
    let iconType: IconTypeViewModel
    let service: ServiceViewModel?
    let options: [OptionViewModel]?
    let company: Company?
    let link: Link?
    let bottomIcon: Image?
    let templateId: PaymentTemplateData.ID?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    private lazy var repeatAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Repeat())
    }
    
    private lazy var closeAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Close())
    }
    
    init(_ model: Model, title: String? = nil, warningTitle: String? = nil, amount: String? = nil, iconType: IconTypeViewModel, additionalButtons: [AdditionalButton]? = nil, service: ServiceViewModel? = nil, options: [OptionViewModel]? = nil, logo: LogoIconViewModel? = nil, transferNumber: TransferNumber? = nil, repeatButton: ButtonSimpleView.ViewModel? = nil, actionButton: ButtonSimpleView.ViewModel, optionButtons: [PaymentsSuccessOptionButtonViewModel], company: Company? = nil, link: Link? = nil, bottomIcon: Image? = nil, templateButton: TemplateButtonView.ViewModel? = nil, templateId: PaymentTemplateData.ID? = nil) {
        
        self.model = model
        self.title = title
        self.warningTitle = warningTitle
        self.amount = amount
        self.iconType = iconType
        self.templateButton = templateButton
        self.additionalButtons = additionalButtons
        self.service = service
        self.options = options
        self.logo = logo
        self.transferNumber = transferNumber
        self.repeatButton = repeatButton
        self.actionButton = actionButton
        self.optionButtons = optionButtons
        self.company = company
        self.link = link
        self.bottomIcon = bottomIcon
        self.templateId = templateId
    }
    
    convenience init(_ model: Model, closeAction: @escaping () -> Void) {
        
        self.init(model, iconType: .success, actionButton: .init(title: "На главный", style: .red, action: closeAction), optionButtons: [])
    }
    
    convenience init(_ model: Model, paymentSuccess: Payments.Success) {
        
        switch paymentSuccess.serviceData {
        case .none:
            
            let product = model.allProducts.first(where: { $0.id == paymentSuccess.productId })
            let amount = model.amountFormatted(amount: paymentSuccess.amount, currencyCode: product?.currency, style: .normal)
            
            self.init(model, documentStatus: paymentSuccess.status, mode: .normal, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [], templateId: nil)
            
            if case let .template(templateId) = paymentSuccess.operation?.source {
                
                refreshTemplateButton = Self.isTemplateEqualPayment(
                    model: model,
                    templateId: templateId,
                    paymentSuccess: paymentSuccess,
                    meToMePayment: nil
                )
            }
            
            bind(
                .normal,
                paymentOperationDetailId: paymentSuccess.operationDetailId,
                documentStatus: paymentSuccess.status,
                operation: paymentSuccess.operation,
                paymentSuccess: paymentSuccess
            )
            
            self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentSuccess.operationDetailId)))
            
        case let .c2bSubscriptionData(c2bSubscribtion):
            
            self.init(model, title: c2bSubscribtion.title, warningTitle: nil, amount: nil, iconType: .init(with: c2bSubscribtion.operationStatus), service: nil, options: nil, logo: nil, repeatButton: nil, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [], company: .init(with: c2bSubscribtion, model: model), link: .init(with: c2bSubscribtion), bottomIcon: .ic72Sbp)
            
        case let .mobileConnectionData(mobileConnectionData):
            
            let (title, iconType) = Self.iconType(status: paymentSuccess.status)
            
            let product = model.allProducts.first(where: { $0.id == paymentSuccess.productId })
            let amount = model.amountFormatted(
                amount: paymentSuccess.amount,
                currencyCode: product?.currency,
                style: .normal
            )
            
            self.init(
                model,
                title: title,
                amount: amount,
                iconType: iconType,
                logo: mobileConnectionData.logo,
                actionButton: .init(
                    title: "На главный",
                    style: .red,
                    action: {}
                ),
                optionButtons: []
            )
            
            if case let .template(templateId) = paymentSuccess.operation?.source {
                
                refreshTemplateButton = Self.isTemplateEqualPayment(
                    model: model,
                    templateId: templateId,
                    paymentSuccess: paymentSuccess,
                    meToMePayment: nil
                )
            }
            
            bind(
                .normal,
                paymentOperationDetailId: paymentSuccess.operationDetailId,
                documentStatus: paymentSuccess.status,
                operation: paymentSuccess.operation,
                paymentSuccess: paymentSuccess
            )
            
            self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentSuccess.operationDetailId)))
            
        case let .paymentsServicesData(paymentsServicesData):
            
            let (title, iconType) = Self.iconType(status: paymentSuccess.status)
            
            let product = model.allProducts.first(where: { $0.id == paymentSuccess.productId })
            let amount = model.amountFormatted(
                amount: paymentSuccess.amount,
                currencyCode: product?.currency,
                style: .normal
            )
            
            self.init(
                model,
                title: title,
                amount: amount,
                iconType: iconType,
                logo: paymentsServicesData.logo,
                actionButton: .init(
                    title: "На главный",
                    style: .red,
                    action: {}
                ),
                optionButtons: []
            )
            
            if case let .template(templateId) = paymentSuccess.operation?.source {
                
                refreshTemplateButton = Self.isTemplateEqualPayment(
                    model: model,
                    templateId: templateId,
                    paymentSuccess: paymentSuccess,
                    meToMePayment: nil
                )
            }
            
            bind(
                .normal,
                paymentOperationDetailId: paymentSuccess.operationDetailId,
                documentStatus: paymentSuccess.status,
                operation: paymentSuccess.operation,
                paymentSuccess: paymentSuccess
            )
            
            self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentSuccess.operationDetailId)))
            
        case let .abroadData(transferData):
            
            let (title, iconType) = Self.iconType(status: paymentSuccess.status)
            
            self.init(
                model,
                title: title,
                amount: nil,
                iconType: iconType,
                logo: nil,
                actionButton: .init(
                    title: "На главный",
                    style: .red,
                    action: {}
                ),
                optionButtons: []
            )
            
            if case let .template(templateId) = paymentSuccess.operation?.source {
                
                refreshTemplateButton = Self.isTemplateEqualPayment(
                    model: model,
                    templateId: templateId,
                    paymentSuccess: paymentSuccess,
                    meToMePayment: nil
                )
            }
            
            bind(
                .normal,
                paymentOperationDetailId: paymentSuccess.operationDetailId,
                documentStatus: paymentSuccess.status,
                operation: paymentSuccess.operation,
                paymentSuccess: paymentSuccess
            )
            
            self.model.action.send(ModelAction.Operation.Detail.Request(
                type: .paymentOperationDetailId(transferData.paymentOperationDetailId)
            ))
            
        case let .returnAbroadData(transferData: transferData, title: title):
            let (_, iconType) = Self.iconType(status: paymentSuccess.status)
            
            self.init(
                model,
                title: title,
                amount: nil,
                iconType: iconType,
                logo: nil,
                actionButton: .init(
                    title: "На главный",
                    style: .red,
                    action: {}
                ),
                optionButtons: []
            )
            
            switch paymentSuccess.operation?.service {
            case .return:
                createDocumentButton(
                    model: model,
                    transferData: transferData,
                    type: .returnOutgoing
                )
                
            case .change:
                createDocumentButton(
                    model: model,
                    transferData: transferData,
                    type: .changeOutgoing
                )
                
            default: break
            }
            
            bind(
                .normal,
                paymentOperationDetailId: paymentSuccess.operationDetailId,
                documentStatus: paymentSuccess.status,
                operation: paymentSuccess.operation
            )
        }
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
    }
    
    convenience init?(
        _ model: Model,
        mode: Mode = .normal,
        transferData: TransferResponseData,
        meToMePayment: MeToMePayment?,
        templateId: PaymentTemplateData.ID?
    ) {
        
        guard let documentStatus = transferData.documentStatus else {
            return nil
        }
        
        let amount = Self.amountFormatted(model, amount: transferData.debitAmount ?? 0, currencyCode: transferData.currencyPayer?.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [], templateId: templateId)
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
        
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId, documentStatus: documentStatus, operation: nil)
        
        if let templateId {
         
            refreshTemplateButton = Self.isTemplateEqualPayment(
                model: model,
                templateId: templateId,
                paymentSuccess: nil,
                meToMePayment: meToMePayment
            )
        }
        
        self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(transferData.paymentOperationDetailId)))
    }
    
    convenience init?(_ model: Model, mode: Mode = .normal, productIdFrom: ProductData.ID?, productIdTo: ProductData.ID?, transferData: TransferResponseData) {
        
        guard let documentStatus = transferData.documentStatus else {
            return nil
        }
        
        let debitAmount = transferData.debitAmount ?? 0
        let amount = Self.amountFormatted(model, amount: debitAmount, currencyCode: transferData.currencyPayer?.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [], templateId: nil)
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
        
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId, documentStatus: documentStatus, operation: nil)
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId, amount: debitAmount, productIdFrom: productIdFrom, productIdTo: productIdTo, documentStatus: documentStatus)
        
        self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(transferData.paymentOperationDetailId)))
    }
    
    convenience init?(_ model: Model, mode: Mode = .normal, currency: Currency, balance: Double, transferData: CloseProductTransferData) {
        
        guard let paymentOperationDetailId = transferData.paymentOperationDetailId else {
            return nil
        }
        
        let documentStatus: TransferResponseData.DocumentStatus = transferData.documentStatus
        
        let amount = Self.amountFormatted(model, amount: balance, currencyCode: currency.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [], templateId: nil)
        
        bind(mode, paymentOperationDetailId: paymentOperationDetailId, documentStatus: documentStatus, operation: nil)
        
        switch mode {
        case .closeAccount(_):
            self.updateButtons(mode, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId)
            
        case .closeAccountEmpty(_):
            self.updateButtons(mode, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId)
            
        default:
            if let paymentOperationDetailId = transferData.paymentOperationDetailId {
                
                self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentOperationDetailId)))
            }
        }
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
    }
    
    convenience init(_ model: Model, documentStatus: TransferResponseBaseData.DocumentStatus, mode: Mode, amount: String?, actionButton: ButtonSimpleView.ViewModel, optionButtons: [PaymentsSuccessOptionButtonViewModel], templateId: PaymentTemplateData.ID?) {
        
        let title = Self.title(mode, documentStatus: documentStatus)
        
        switch documentStatus {
        case .complete:
            
            self.init(model, title: title, amount: amount, iconType: .success, actionButton: actionButton, optionButtons: optionButtons, templateId: templateId)
            
        case .inProgress:
            
            self.init(model, title: title, amount: amount, iconType: .accepted, actionButton: actionButton, optionButtons: [], templateId: templateId)
            
        case .rejected, .unknown:
            switch mode {
            case .makePaymentToDeposite, .closeDeposit:
                self.init(model, title: title, amount: amount, iconType: .error, actionButton: actionButton, optionButtons: [], templateId: templateId)
            default:
                self.init(model, title: title, amount: amount, iconType: .error, actionButton: actionButton, optionButtons: [], templateId: templateId)
                repeatButton = .init(title: "Повторить", style: .gray, action: repeatAction)
                
            }
        }
    }
    
    private func bind(
        _ mode: Mode,
        paymentOperationDetailId: Int,
        documentStatus: TransferResponseBaseData.DocumentStatus,
        operation: Payments.Operation?,
        paymentSuccess: Payments.Success? = nil
    ) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Operation.Detail.Response:
                    
                    switch payload.result {
                    case let .success(detailData):
                        
                        switch mode {
                        case .closeAccount(_):
                            let viewModel: OperationDetailInfoViewModel = .init(model: self.model, operation: detailData, dismissAction: {
                                
                                self.sheet = nil
                            })
                            
                            self.action.send(PaymentsSuccessAction.OptionButton.Details.Tap(viewModel: viewModel))
                            
                        default:
                            switch detailData.transferEnum {
                            case .direct, .elecsnet:
                                let image = Image("MigAvatar")
                                self.logo = operation?.service == .abroad ? .init(title: "", image: image) : nil
                                let amount = detailData.amount
                                
                                self.amount = model.amountFormatted(amount: amount, currencyCode: detailData.currencyAmount, style: .fraction)
                                
                            case .contactAddressing, .contactAddressless, .contactAddressingCash:
                                self.logo = .init(title: "", image: Image("Operation Type Contact Icon"))
                                
                                if let number = detailData.transferReference {
                                    
                                    if let amount = detailData.payeeAmount {
                                        
                                        self.amount = model.amountFormatted(amount: amount, currencyCode: detailData.currencyAmount, style: .fraction)
                                    }
                                    
                                    self.transferNumber = .init(title: number, state: .copy(action: { [weak self] in
                                        
                                        self?.action.send(PaymentsSuccessAction.TransferNumber.Copy(number: number))
                                    }))
                                    
                                    var additionalButtons: [AdditionalButton] = []
                                    
                                    if let name = detailData.payeeFullName {
                                        
                                        additionalButtons.append(.init(title: "Изменить", action: { [weak self] in
                                            
                                            self?.action.send(PaymentsSuccessAction.Payment(source: .change(operationId: detailData.paymentOperationDetailId.description,transferNumber: number, name: name)))
                                        }))
                                    }
                                    
                                    let amountValue = detailData.payerAmount - detailData.payerFee
                                    if let amount = model.amountFormatted(amount: amountValue, currencyCode: detailData.payerCurrency, style: .fraction) {
                                        additionalButtons.append(.init(title: "Вернуть", action: { [weak self] in
                                            
                                            self?.action.send(PaymentsSuccessAction.Payment(source: .return(operationId: detailData.paymentOperationDetailId, transferNumber: number, amount: amount, productId: detailData.payerCardId?.description ?? detailData.payerAccountId.description)))
                                        }))
                                    }
                                    
                                    self.additionalButtons = additionalButtons
                                }
                                
                            default: break
                            }
                        }
                        
                        switch payload.result {
                        case let .success(operationDetailData):
                            
                            guard operationDetailData.restrictedTemplateButton else {
                                break
                            }
                            
                            switch operation?.source {
                            case let .template(templateId):
                                
                                guard let template = self.model.paymentTemplates.value.first(where: { $0.id == templateId }) else {
                                    return
                                }
                                
                                templateButton = .init(
                                    state: self.refreshTemplateButton ? .complete : .refresh,
                                    model: model,
                                    tapAction: { [weak self] in
                                        
                                        guard let paymentSuccess else {
                                            return
                                        }
                                        
                                        self?.templateButton?.state = .loading(isComplete: true)

                                        if self?.refreshTemplateButton == false {
                                            
                                            self?.model.action.send(ModelAction.PaymentTemplate.Update.Requested(
                                                name: template.name,
                                                parameterList: self?.templateParameterList(
                                                    operationDetail: detailData,
                                                    operation: operation,
                                                    paymentSuccess: paymentSuccess
                                                ),
                                                paymentTemplateId: templateId)
                                            )
                                            
                                        } else {
                                            
                                            self?.model.action.send(ModelAction.PaymentTemplate.Delete.Requested(
                                                paymentTemplateIdList: [
                                                    templateId
                                                ]
                                            ))
                                        }
                                    }
                                )
                                
                            default:
                                
                                if let templateId = self.templateId {
                                    guard let template = self.model.paymentTemplates.value.first(where: { $0.id == self.templateId }) else {
                                        return
                                    }
                                    
                                    templateButton = .init(
                                        state: self.refreshTemplateButton ? .complete : .refresh,
                                        model: model,
                                        tapAction: { [weak self] in
                                            
                                            guard let model = self?.model else {
                                                return
                                            }
                                            
                                            self?.templateButton?.state = .loading(isComplete: true)

                                            if self?.refreshTemplateButton == false {
                                                
                                                self?.model.action.send(ModelAction.PaymentTemplate.Update.Requested(
                                                    name: template.name,
                                                    parameterList: self?.createMe2MeParameterList(
                                                        model: model,
                                                        operationDetail: detailData,
                                                        template: template),
                                                    
                                                    paymentTemplateId: template.id)
                                                )
                                                
                                            } else {
                                                
                                                self?.model.action.send(ModelAction.PaymentTemplate.Delete.Requested(
                                                    paymentTemplateIdList: [
                                                        template.id
                                                    ]
                                                ))
                                            }
                                        }
                                    )
                                } else {
                                    
                                    self.templateButton = .init(model: model, operationDetail: detailData)
                                }
                            }
                            
                            bindTemplate(operationDetail: operationDetailData,
                                         paymentOperationDetailId: paymentOperationDetailId)
                        case .failure:
                            model.action.send(ModelAction.Informer.Show(informer: .init(message: "Ошибка получения данных", icon: .close)))
                        }
                        
                        handleDetailResponse(mode, payload: payload, documentStatus: documentStatus)
                        
                    case let .failure(error):
                        //MARK: Informer Detail Error
                        model.action.send(ModelAction.Informer.Show(informer: .init(message: "Ошибка получения данных", icon: .close)))
                        
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "ModelAction.Operation.Detail.Response error: \(error)")
                    }
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? DelayWrappedAction })
            .flatMap({
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: DispatchQueue.main)
                
            })
            .sink(receiveValue: { [weak self] in
                
                self?.action.send($0)
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? PaymentsSuccessAction.TransferNumber.Copy })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] payload in
                
                UIPasteboard.general.string = payload.number
                
                withAnimation {
                    
                    self.transferNumber = .init(title: payload.number, state: .check)
                }
                
                self.action.send(DelayWrappedAction(delayMS: 2000, action: PaymentsSuccessAction.TransferNumber.Check(number: payload.number)))
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? PaymentsSuccessAction.TransferNumber.Check })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] payload in
                
                withAnimation {
                    
                    self.transferNumber = .init(title: payload.number, state: .copy(action: { [weak self] in
                        
                        self?.action.send(PaymentsSuccessAction.TransferNumber.Copy(number: payload.number))
                    }))
                }
                
            }).store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsSuccessAction.OptionButton.Details.Tap:
                    
                    self.sheet = .init(type: .detailInfo(payload.viewModel))
                    
                case _ as PaymentsSuccessAction.Button.Close:
                    
                    model.action.send(ModelAction.Products.Update.Total.All())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bindTemplate(
        operationDetail: OperationDetailData,
        paymentOperationDetailId: Int
    ) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.PaymentTemplate.Save.Complete:
                    
                    self.templateButton = .init(
                        state: .complete,
                        model: model,
                        tapAction: { [weak self] in
                            
                            self?.model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [payload.paymentTemplateId]))
                        })
                    
                case _ as ModelAction.PaymentTemplate.Delete.Complete:
                    
                    self.templateButton = .init(
                        state: .idle,
                        model: model,
                        tapAction: { [weak self] in
                            
                            self?.templateButton?.state = .loading(isComplete: false)
                            self?.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: operationDetail.templateName, paymentOperationDetailId: paymentOperationDetailId))
                        }
                    )
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        Publishers.Merge3(
            model.action
                .compactMap { $0 as? ModelAction.PaymentTemplate.Update.Failed }
                .map { _ in "Не удалось обновить шаблон" },
            model.action
                .compactMap { $0 as? ModelAction.PaymentTemplate.Delete.Failed }
                .map { _ in "Не удалось удалить шаблон" },
            model.action
                .compactMap { $0 as? ModelAction.PaymentTemplate.Save.Failed }
                .map { _ in "Не удалось добавить шаблон" }
        )
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] message in
            
            self.model.action.send(ModelAction.Informer.Show(informer: .init(message: message, icon: .check)))
            
        }.store(in: &bindings)
    }
    
    private func bind(_ mode: Mode, paymentOperationDetailId: Int, amount: Double, productIdFrom: ProductData.ID?, productIdTo: ProductData.ID?, documentStatus: TransferResponseBaseData.DocumentStatus) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as ModelAction.Operation.Detail.Response:
                    
                    guard let productIdFrom = productIdFrom,
                          let productIdTo = productIdTo,
                          let productFrom = model.product(productId: productIdFrom),
                          let productTo = model.product(productId: productIdTo) else {
                        return
                    }
                    
                    let detailData: OperationDetailData = makeDetailData(amount: amount, productFrom: productFrom, productTo: productTo, paymentOperationDetailId: paymentOperationDetailId, transferEnum: .conversionCardToAccount)
                    
                    let payload = ModelAction.Operation.Detail.Response(result: .success(detailData))
                    
                    handleDetailResponse(mode, payload: payload, documentStatus: documentStatus)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func updateButtons(_ mode: Mode, documentStatus: TransferResponseBaseData.DocumentStatus, paymentOperationDetailId: Int, operationDetail: OperationDetailData? = nil) {
        
        optionButtons = makeOptionButtons(mode, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail)
    }
}

extension PaymentsSuccessViewModel {
    
    struct TransferNumber {
        
        let title: String
        let state: State
        
        enum State {
            
            case copy(action: () -> Void)
            case check
        }
    }
    
    struct FullScreenSheet: Identifiable, Equatable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case abroad(PaymentsViewModel)
        }
        
        static func == (lhs: PaymentsSuccessViewModel.FullScreenSheet, rhs: PaymentsSuccessViewModel.FullScreenSheet) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    struct AdditionalButton: Identifiable {
        
        let id = UUID()
        let title: String
        let action: () -> Void
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case printForm(PrintFormView.ViewModel)
            case detailInfo(OperationDetailInfoViewModel)
        }
    }
    
    enum Mode {
        
        case normal
        case meToMe
        case closeDeposit
        case closeAccount(ProductData.ID)
        case closeAccountEmpty(ProductData.ID)
        case makePaymentToDeposite
    }
    
    enum OptionButtonType {
        
        case document
        case details
    }
}

extension PaymentsSuccessViewModel {
    
    enum IconTypeViewModel {
        
        case success
        case accepted
        case transfer
        case error
        
        var image: Image {
            
            switch self {
            case .success: return .ic48Check
            case .accepted: return .ic48Clock
            case .transfer: return .ic48UploadToAccount
            case .error: return .ic48Close
            }
        }
        
        var color: Color {
            
            switch self {
            case .success: return .systemColorActive
            case .accepted: return .systemColorWarning
            case .transfer: return .systemColorWarning
            case .error: return .systemColorError
            }
        }
    }
    
    struct LogoIconViewModel {
        
        let title: String
        let image: Image
    }
    
    struct LogoIconViewModel2 {
        
        let title: String
        let image: Image
    }
    
    struct ServiceViewModel {
        
        let title: String
        let description: String
    }
    
    struct OptionViewModel: Identifiable {
        
        let id: UUID = .init()
        let image: Image
        let title: String
        let subTitle: String?
        let description: String
    }
    
    struct Company {
        
        let icon: Image
        let name: String?
        
        init(icon: Image, name: String?) {
            
            self.icon = icon
            self.name = name
        }
    }
    
    enum FullScreen {
        
        case abroad(PaymentsViewModel)
    }
    
    struct Link {
        
        let icon: Image
        let title: String
        let url: URL
        
        init(icon: Image = .ic24ExternalLink, title: String, url: URL) {
            
            self.icon = icon
            self.title = title
            self.url = url
        }
    }
}

extension PaymentsSuccessViewModel.IconTypeViewModel {
    
    init(with status: C2BSubscriptionData.Status) {
        
        switch status {
        case .complete:
            self = .success
            
        case .rejected:
            self = .error
            
        default:
            self = .accepted
        }
    }
}

extension PaymentsSuccessViewModel.Company {
    
    init(with data: C2BSubscriptionData, model: Model) {
        
        if let companyLogoData = model.images.value[data.brandIcon],
           let companyLogo = companyLogoData.image {
            
            self.init(icon: companyLogo, name: data.brandName)
            
        } else {
            
            self.init(icon: .ic40Goods, name: data.brandName)
        }
    }
}

extension PaymentsSuccessViewModel.Link {
    
    init?(with data: C2BSubscriptionData) {
        
        guard let url = data.redirectUrl else {
            return nil
        }
        
        self.init(title: "Вернуться в магазин", url: url)
    }
}

class PaymentsSuccessOptionButtonViewModel: Identifiable {
    
    let id: UUID = .init()
    let icon: Image
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var color: Color {
        
        switch isSelected {
        case true: return Color(hex: "#22C184")
        case false: return Color(hex: "#F6F6F7")
        }
    }
    
    var iconColor: Color {
        
        switch isSelected {
        case true: return .mainColorsWhite
        case false: return .mainColorsBlack
        }
    }
    
    init(icon: Image, title: String, isSelected: Bool = false, action: @escaping () -> Void) {
        
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
}

extension PaymentsSuccessViewModel {
    
    static func title(_ mode: Mode, documentStatus: TransferResponseBaseData.DocumentStatus) -> String {
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .normal, .meToMe, .closeDeposit, .closeAccount, .makePaymentToDeposite: return "Успешный перевод"
            case .closeAccountEmpty: return "Счет успешно закрыт"
            }
            
        case .inProgress:
            
            switch mode {
            case .normal, .closeAccount, .closeDeposit, .closeAccountEmpty, .makePaymentToDeposite: return "Платеж принят в обработку"
            case .meToMe: return "Операция в обработке!"
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .closeDeposit, .closeAccount: return .init()
            case .meToMe, .makePaymentToDeposite: return "Операция неуспешна!"
            case .closeAccountEmpty: return "Отказ"
            }
        }
    }
    
    static func iconType(status: TransferResponseBaseData.DocumentStatus) -> (String, IconTypeViewModel) {
        
        switch status {
        case .complete:
            return ("Успешный перевод", .success)
        case .inProgress:
            return ("Операция в обработке!", .accepted)
        case .rejected, .unknown:
            return ("Операция неуспешна!", .error)
        }
    }
    
    static func amountFormatted(_ model: Model, amount: Double, currencyCode: String?) -> String? {
        
        let amountFormatted = model.amountFormatted(amount: amount, currencyCode: currencyCode, style: .fraction)
        let amount = amount == 0 ? nil : amountFormatted
        
        return amount
    }
    
    private func makeOptionButtons(_ mode: Mode, documentStatus: TransferResponseBaseData.DocumentStatus, paymentOperationDetailId: Int, operationDetail: OperationDetailData? = nil) -> [PaymentsSuccessOptionButtonViewModel] {
        
        let documentButton = optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail)
        let detailButton =   optionButton(mode, type: .details,  paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail)
        
        let buttons: [PaymentsSuccessOptionButtonView.ViewModel?]
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .normal, .meToMe:
                buttons = [documentButton, detailButton]
                
            case .makePaymentToDeposite:
                buttons = [documentButton, detailButton]
                
            case .closeDeposit, .closeAccount:
                buttons = [documentButton, detailButton]
                
            case .closeAccountEmpty:
                buttons = [documentButton]
            }
            
        case .inProgress:
            
            switch mode {
            case .closeAccount, .closeAccountEmpty:
                return []
                
            case .meToMe, .normal:
                buttons = [detailButton]
                
            case .makePaymentToDeposite, .closeDeposit:
                buttons = [detailButton]
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .closeAccount, .closeAccountEmpty:
                return []
                
            case .meToMe, .makePaymentToDeposite, .closeDeposit:
                buttons = [detailButton]
            }
        }
        
        return buttons.compactMap { $0 }
    }

    private func optionButton(_ mode: Mode, type: OptionButtonType, paymentOperationDetailId: Int = 0, operationDetail: OperationDetailData? = nil) -> PaymentsSuccessOptionButtonView.ViewModel? {
        
        switch type {
            
        case .document:
            
            return .init(icon: .ic24File, title: "Документ") { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                switch mode {
                case .normal, .meToMe, .closeDeposit, .makePaymentToDeposite:
                    
                    guard let operationDetail = operationDetail else {
                        return
                    }
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .operation(paymentOperationDetailId: paymentOperationDetailId, printFormType: operationDetail.printFormType), model: self.model)
                    self.sheet = .init(type: .printForm(printViewModel))
                    
                case let .closeAccount(productDataId):
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .closeAccount(id: productDataId, paymentOperationDetailId: paymentOperationDetailId), model: self.model)
                    
                    self.sheet = .init(type: .printForm(printViewModel))
                    
                case let .closeAccountEmpty(productId):
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .closeAccountEmpty(id: productId), model: self.model)
                    
                    self.sheet = .init(type: .printForm(printViewModel))
                }
            }
            
        case .details:
            
            return .init(icon: .ic24Info, title: "Детали") { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                switch mode {
                case .closeAccount(_):
                    self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentOperationDetailId)))
                    
                default:
                    guard let operationDetail = operationDetail else {
                        self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentOperationDetailId)))
                        return
                    }
                    
                    let viewModel: OperationDetailInfoViewModel = .init(model: self.model, operation: operationDetail, dismissAction: {
                        
                        self.sheet = nil
                    })
                    
                    self.action.send(PaymentsSuccessAction.OptionButton.Details.Tap(viewModel: viewModel))
                }
            }
        }
    }
    
    private func handleDetailResponse(_ mode: Mode, payload: ModelAction.Operation.Detail.Response, documentStatus: TransferResponseBaseData.DocumentStatus) {
        
        switch payload.result {
        case let .success(detailData):
            
            withAnimation {
                
                updateButtons(mode, documentStatus: documentStatus, paymentOperationDetailId: detailData.paymentOperationDetailId, operationDetail: detailData)
            }
            
        case .failure:
            //TODO: show alert
            break
        }
    }
}

// MARK: - Action

enum PaymentsSuccessAction {
    
    enum Button {
        
        struct Close: Action {}
        struct Repeat: Action {}
    }
    
    struct Payment: Action {
        
        let source: Payments.Operation.Source
    }
    
    enum OptionButton {
        
        enum Template {
            
            struct Tap: Action {}
        }
        
        enum Document {
            
            struct Tap: Action {}
        }
        
        enum Details {
            
            struct Tap: Action {
                
                let viewModel: OperationDetailInfoViewModel
            }
        }
    }
    
    enum TransferNumber {
        
        struct Copy: Action {
            
            let number: String
        }
        
        struct Check: Action {
            
            let number: String
        }
    }
}

extension PaymentsSuccessViewModel {
    
    func createDocumentButton(
        model: Model,
        transferData: TransferResponseBaseData,
        type: PrintFormType
    ) {
        
        let documentButton: PaymentsSuccessOptionButtonView.ViewModel = .init(
            icon: .ic24File,
            title: "Документ",
            action: {
                
                self.sheet = .init(
                    type: .printForm(
                        .init(
                            type: .operation(
                                paymentOperationDetailId: transferData.paymentOperationDetailId,
                                printFormType: type
                            ),
                            model: model
                        )))
                
            })
        
        self.optionButtons = [documentButton]
    }
}

extension PaymentsSuccessViewModel {
    
    func makeDetailData(amount: Double, productFrom: ProductData, productTo: ProductData, paymentOperationDetailId: Int, transferEnum: OperationDetailData.TransferEnum) -> OperationDetailData {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        
        return .init(oktmo: nil, account: nil, accountTitle: nil, amount: amount, billDate: nil, billNumber: nil, claimId: UUID().uuidString, comment: "Перевод с конверсией денежных средств между счетами Клиента", countryName: nil, currencyAmount: productFrom.currency, dateForDetail: date, division: nil, driverLicense: nil, externalTransferType: nil, isForaBank: nil, isTrafficPoliceService: false, memberId: nil, operation: "Перевод денежных средств между счетами Клиента с конверсией по курсу банка", payeeAccountId: productTo.id, payeeAccountNumber: productTo.accountNumber, payeeAmount: productTo.balanceValue, payeeBankBIC: nil, payeeBankCorrAccount: nil, payeeBankName: productTo.displayName, payeeCardId: nil, payeeCardNumber: productTo.number, payeeCurrency: productTo.currency, payeeFirstName: nil, payeeFullName: productTo.productName, payeeINN: nil, payeeKPP: nil, payeeMiddleName: nil, payeePhone: nil, payeeSurName: nil, payerAccountId: productFrom.id, payerAccountNumber: productFrom.accountNumber ?? "", payerAddress: "", payerAmount: amount, payerCardId: productFrom.id, payerCardNumber: productFrom.number, payerCurrency: productFrom.currency, payerDocument: nil, payerFee: 0, payerFirstName: productFrom.displayName, payerFullName: productFrom.productName, payerINN: nil, payerMiddleName: productFrom.displayName, payerPhone: nil, payerSurName: nil, paymentOperationDetailId: paymentOperationDetailId, paymentTemplateId: nil, period: nil, printFormType: .internal, provider: nil, puref: nil, regCert: nil, requestDate: date, responseDate: date, returned: nil, transferDate: date, transferEnum: transferEnum, transferNumber: nil, transferReference: nil, cursivePayerAmount: nil, cursivePayeeAmount: nil, cursiveAmount: nil, serviceSelect: nil, serviceName: nil, merchantSubName: nil, merchantIcon: nil, operationStatus: nil, shopLink: nil, payeeCheckAccount: nil, depositNumber: nil, depositDateOpen: nil, currencyRate: nil, mcc: nil, printData: nil, paymentMethod: nil)
    }
}

private extension MobileConnectionData {
    
    var logo: PaymentsSuccessViewModel.LogoIconViewModel? {
        
        let svgImageData = svgImageData
        let imageData = ImageData(with: svgImageData)
        
        guard let image = imageData?.image else {
            return nil
        }
        
        return .init(title: "", image: image)
    }
}

private extension PaymentsServicesData {
    
    var logo: PaymentsSuccessViewModel.LogoIconViewModel? {
        
        let svgImageData = svgImageData
        let imageData = ImageData(with: svgImageData)
        
        guard let image = imageData?.image else {
            return nil
        }
        
        return .init(title: "", image: image)
    }
}

extension PaymentsSuccessViewModel {
    
    static func isTemplateEqualPayment(
        model: Model,
        templateId: PaymentTemplateData.ID,
        paymentSuccess: Payments.Success?,
        meToMePayment: MeToMePayment?
    ) -> Bool {
        
        guard let template = model.paymentTemplates.value.first(where: { $0.id == templateId }) else {
            return true
        }
        
        if let paymentSuccess {
            
            if let amountTemplate = template.amount?.description,
               let amount = Double(amountTemplate),
               paymentSuccess.amount.description != amount.description {
                
                return false
            }
            
            let productPaymentTemplate = paymentSuccess.productId
            
            if template.parameterList.last?.payer?.productIdDescription != productPaymentTemplate.description {
                
                return false
            }
            
            switch template.parameterList.last {
            case let payload as TransferGeneralData:
                
                switch paymentSuccess.operation?.service {
                case .toAnotherCard:
                    let anotherCard = paymentSuccess.operation?.parameters.first(where: {$0.id == Payments.Parameter.Identifier.productTemplate.rawValue })
                    
                    guard let generalData = template.parameterList.last as? TransferGeneralData,
                          let payeeInternalId = generalData.payeeInternal?.cardId ?? generalData.payeeInternal?.accountId else {
                        return true
                    }
                    
                    if anotherCard?.value?.digits != payeeInternalId.description {
                        
                        return false
                        
                    } else {
                        
                        return true
                    }
                    
                default:
                 
                    let inn = paymentSuccess.operation?.parameters.first(where: { $0.id == Payments.Parameter.Identifier.requisitsInn.rawValue })?.value
                    let kpp = paymentSuccess.operation?.parameters.first(where: { $0.id == Payments.Parameter.Identifier.requisitsKpp.rawValue })?.value
                    let accountNumber = paymentSuccess.operation?.parameters.first(where: { $0.id == Payments.Parameter.Identifier.requisitsAccountNumber.rawValue })?.value
                    let name = paymentSuccess.operation?.parameters.first(where: { $0.id == Payments.Parameter.Identifier.requisitsCompanyName.rawValue })?.value
                    let comment = paymentSuccess.operation?.parameters.first(where: { $0.id == Payments.Parameter.Identifier.requisitsMessage.rawValue })?.value
                    
                    guard let payeeExternal = payload.payeeExternal else {
                        return true
                    }
                    
                    if payeeExternal.inn?.description != inn || payeeExternal.kpp != kpp || payeeExternal.accountNumber != accountNumber || payeeExternal.name != name || template.parameterList.first?.comment != comment {
                        
                        return false
                    } else {
                        
                        return true
                    }
                }
                
            case let payload as TransferAnywayData:
                let additional = Self.additionalPayments(
                    model: model,
                    service: paymentSuccess.service,
                    paymentSuccess: paymentSuccess
                )
                
                if let additional {
                    
                    let values = additional.map(\.fieldvalue)
                    
                    for additional in payload.additional {
                        
                        if additional.fieldvalue.contained(in: values) || additional.fieldvalue.isEmpty {
                            continue
                        } else {
                            
                            return false
                        }
                    }
                    
                } else {
                    
                    return true
                }
                
            default: break
                
            }
            
        } else {
            
            guard let meToMePayment else {
                return true
            }
            
            switch template.parameterList.last {
            case let payload as TransferGeneralData:
                
                guard let payeeProductId = payload.payeeInternal?.cardId ?? payload.payeeInternal?.accountId,
                      let amountDescription = payload.amount?.description,
                      let amount = Double(amountDescription),
                      let payerProductId = payload.payer?.cardId ?? payload.payer?.accountId else {
                    
                    return true
                }
                
                let templatePayment = MeToMePayment(
                    payerProductId: payerProductId,
                    payeeProductId: payeeProductId,
                    amount: amount
                )
                
                if templatePayment != meToMePayment {
                    
                    return false
                } else {
                    
                    return true
                }
                
                
            default:
                return true
            }
        }
        
        return true
    }
    
    static func additionalPayments(
        model: Model,
        service: Payments.Service?,
        paymentSuccess: Payments.Success
    ) ->  [TransferAnywayData.Additional]? {
        
        let lastStep = paymentSuccess.operation?.steps.filter({ !$0.contains(parameterId: Payments.Parameter.Identifier.code.rawValue) }).last
        
        guard let parameters = paymentSuccess.operation?.parameters,
              let processed = lastStep?.back.processed else {
            return nil
        }
        
        switch service {
        case .abroad:
            return try? model.paymentsTransferAnywayAbroadAdditional(
                parameters,
                restrictedParameters: model.restrictedParametersAbroad
            )
            
        case .sfp:
            return try? model.paymentsTransferSFPAdditional(
                processed,
                allParameters: parameters
            )
            
        case .transport,
                .requisites,
                .avtodor,
                .fms,
                .fns,
                .fssp,
                .gibdd,
                .internetTV,
                .utility,
                .mobileConnection:
            
            return try? model.paymentsTransferPaymentsServicesAdditional(
                parameters,
                excludingParameters: []
            )
            
        default:
            return nil
        }
    }
    
    private func createMe2MeParameterList(
        model: Model,
        operationDetail: OperationDetailData,
        template: PaymentTemplateData
    ) -> [TransferData]? {
        
        let payerProductId = operationDetail.payerCardId ?? operationDetail.payerAccountId
        guard let templateParameterList = template.parameterList.last as? TransferGeneralData,
              let payeeProductId = templateParameterList.payeeInternal?.accountId ?? templateParameterList.payeeInternal?.cardId,
              let payee = model.allProducts.first(where: {$0.id == payeeProductId }),
              let payerData = model.allProducts.first(where: { $0.id == payerProductId }),
              let payer = TransferGeneralData.Payer(productData: payerData) else {
            return nil
        }
        
        return [TransferGeneralData(
            amount: Decimal(string: operationDetail.amount.description),
            check: false,
            comment: nil,
            currencyAmount: operationDetail.currencyAmount,
            payer: payer,
            payeeExternal: nil,
            payeeInternal: .init(productData: payee)
        )]
    }
    
    private func templateParameterList(
        operationDetail: OperationDetailData,
        operation: Payments.Operation?,
        paymentSuccess: Payments.Success
    ) -> [TransferData]? {
        
        switch operation?.service {
        case .toAnotherCard:
            return [
                TransferGeneralData(
                    amount: Decimal(string: operationDetail.amount.description),
                    check: false,
                    comment: nil,
                    currencyAmount: operationDetail.currencyAmount,
                    payer: .init(
                        inn: nil,
                        accountId: operationDetail.payerAccountId,
                        accountNumber: operationDetail.payerAccountNumber,
                        cardId: operationDetail.payerCardId,
                        cardNumber: operationDetail.payerCardNumber,
                        phoneNumber: nil
                    ),
                    payeeExternal: nil,
                    payeeInternal: .init(
                        accountId: operationDetail.payeeAccountId,
                        accountNumber: operationDetail.payeeAccountNumber,
                        cardId: operationDetail.payeeCardId,
                        cardNumber: operationDetail.payeeCardNumber,
                        phoneNumber: nil,
                        productCustomName: nil
                    )
                )
            ]
        case .requisites:
            guard let payeeAccountNumber = operationDetail.payeeAccountNumber,
                  let fullName = operationDetail.payeeFullName else {
                return nil
            }
            
            return [
                TransferGeneralData(
                    amount: Decimal(string: operationDetail.amount.description),
                    check: false,
                    comment: operationDetail.comment,
                    currencyAmount: operationDetail.currencyAmount,
                    payer: .init(
                        inn: nil,
                        accountId: operationDetail.payerAccountId,
                        accountNumber: operationDetail.payerAccountNumber,
                        cardId: operationDetail.payerCardId,
                        cardNumber: operationDetail.payerCardNumber,
                        phoneNumber: nil
                    ),
                    payeeExternal: .init(
                        inn: operationDetail.payeeINN,
                        kpp: operationDetail.payeeKPP,
                        accountId: operationDetail.payeeAccountId,
                        accountNumber: payeeAccountNumber,
                        bankBIC: operationDetail.payeeBankBIC,
                        cardId: operationDetail.payeeCardId,
                        cardNumber: operationDetail.payeeCardNumber,
                        compilerStatus: nil,
                        date: nil,
                        name: fullName,
                        tax: nil
                    ),
                    payeeInternal: nil
                )
            ]
        default:
            let additional = Self.additionalPayments(
                model: model,
                service: operation?.service,
                paymentSuccess: paymentSuccess
            )
            
            guard let additional else {
                return nil
            }
            
            return [
                TransferAnywayData(
                    amount: Decimal(string: operationDetail.amount.description),
                    check: false,
                    comment: operationDetail.comment,
                    currencyAmount: operationDetail.currencyAmount,
                    payer: .init(
                        inn: nil,
                        accountId: operationDetail.payerAccountId,
                        accountNumber: operationDetail.payerAccountNumber,
                        cardId: operationDetail.payerCardId,
                        cardNumber: operationDetail.payerCardNumber,
                        phoneNumber: nil
                    ),
                    additional: additional,
                    puref: operationDetail.puref
                )
            ]
        }
    }
}
