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
    @Published var additioinalButtons: [AdditionalButton]?
    @Published var sheet: Sheet?
    @Published var isLinkActive: Bool = false
    @Published var fullScreenSheet: FullScreenSheet?
    @Published var alert: Alert.ViewModel?
    
    var amount: String?
    var transferNumber: TransferNumber?
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
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    private lazy var repeatAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Repeat())
    }
    
    private lazy var closeAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Close())
    }
    
    init(_ model: Model, title: String? = nil, warningTitle: String? = nil, amount: String? = nil, iconType: IconTypeViewModel, additioinalButtons: [AdditionalButton]? = nil, service: ServiceViewModel? = nil, options: [OptionViewModel]? = nil, logo: LogoIconViewModel? = nil, transferNumber: TransferNumber? = nil, repeatButton: ButtonSimpleView.ViewModel? = nil, actionButton: ButtonSimpleView.ViewModel, optionButtons: [PaymentsSuccessOptionButtonViewModel], company: Company? = nil, link: Link? = nil, bottomIcon: Image? = nil) {
        
        self.model = model
        self.title = title
        self.warningTitle = warningTitle
        self.amount = amount
        self.iconType = iconType
        self.additioinalButtons = additioinalButtons
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
    }
    
    convenience init(_ model: Model, closeAction: @escaping () -> Void) {
        
        self.init(model, iconType: .success, actionButton: .init(title: "На главный", style: .red, action: closeAction), optionButtons: [])
    }
    
    convenience init(_ model: Model, paymentSuccess: Payments.Success) {
        
        switch paymentSuccess.serviceData {
        case .none:
            
            let product = model.allProducts.first(where: { $0.id == paymentSuccess.productId })
            let amount = model.amountFormatted(amount: paymentSuccess.amount, currencyCode: product?.currency, style: .normal)
            
            self.init(model, documentStatus: paymentSuccess.status, mode: .normal, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])
            
            bind(.normal, paymentOperationDetailId: paymentSuccess.operationDetailId, documentStatus: paymentSuccess.status)
            
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
            
            bind(.normal, paymentOperationDetailId: paymentSuccess.operationDetailId, documentStatus: paymentSuccess.status)
            
            self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentSuccess.operationDetailId)))
            
        case let .abroadPayments(transferData):
            
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
                        
            bind(.normal, paymentOperationDetailId: paymentSuccess.operationDetailId, documentStatus: paymentSuccess.status)

            self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(transferData.paymentOperationDetailId)))
            
        }
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
    }
    
    convenience init?(_ model: Model, mode: Mode = .normal, transferData: TransferResponseData) {
        
        guard let documentStatus = transferData.documentStatus else {
            return nil
        }
        
        let amount = Self.amountFormatted(model, amount: transferData.debitAmount ?? 0, currencyCode: transferData.currencyPayer?.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
        
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId, documentStatus: documentStatus)
        
        self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(transferData.paymentOperationDetailId)))
    }
    
    convenience init?(_ model: Model, mode: Mode = .normal, productIdFrom: ProductData.ID?, productIdTo: ProductData.ID?, transferData: TransferResponseData) {
        
        guard let documentStatus = transferData.documentStatus else {
            return nil
        }
        
        let debitAmount = transferData.debitAmount ?? 0
        let amount = Self.amountFormatted(model, amount: debitAmount, currencyCode: transferData.currencyPayer?.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
        
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId, documentStatus: documentStatus)
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId, amount: debitAmount, productIdFrom: productIdFrom, productIdTo: productIdTo, documentStatus: documentStatus)
        
        self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(transferData.paymentOperationDetailId)))
    }
    
    convenience init?(_ model: Model, mode: Mode = .normal, currency: Currency, balance: Double, transferData: CloseProductTransferData) {
        
        guard let paymentOperationDetailId = transferData.paymentOperationDetailId else {
            return nil
        }
        
        let documentStatus: TransferResponseData.DocumentStatus = transferData.documentStatus
        
        let amount = Self.amountFormatted(model, amount: balance, currencyCode: currency.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])
        
        bind(mode, paymentOperationDetailId: paymentOperationDetailId, documentStatus: documentStatus)
        
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
    
    convenience init(_ model: Model, documentStatus: TransferResponseBaseData.DocumentStatus, mode: Mode, amount: String?, actionButton: ButtonSimpleView.ViewModel, optionButtons: [PaymentsSuccessOptionButtonViewModel]) {
        
        let title = Self.title(mode, documentStatus: documentStatus)
        
        switch documentStatus {
        case .complete:
            
            self.init(model, title: title, amount: amount, iconType: .success, actionButton: actionButton, optionButtons: optionButtons)
            
        case .inProgress:
            
            self.init(model, title: title, amount: amount, iconType: .accepted, actionButton: actionButton, optionButtons: [])
            
        case .rejected, .unknown:
            switch mode {
            case .makePaymentToDeposite, .closeDeposit:
                self.init(model, title: title, amount: amount, iconType: .error, actionButton: actionButton, optionButtons: [])
            default:
                self.init(model, title: title, amount: amount, iconType: .error, actionButton: actionButton, optionButtons: [])
                repeatButton = .init(title: "Повторить", style: .gray, action: repeatAction)

            }
        }
    }
    
    private func bind(_ mode: Mode, paymentOperationDetailId: Int, documentStatus: TransferResponseBaseData.DocumentStatus) {
        
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
                            case .direct:
                                self.logo = .init(title: "", image: Image("MigAvatar"))
                                
                            case .contactAddressing, .contactAddressless, .contactAddressingCash:
                                self.logo = .init(title: "", image: Image("Operation Type Contact Icon"))
                                
                                if let number = detailData.transferReference {
                                    
                                    if let amount = detailData.payeeAmount {
                                        
                                        self.amount = model.amountFormatted(amount: amount, currencyCode: detailData.currencyAmount, style: .fraction)
                                    }
                                    
                                    self.transferNumber = .init(title: number, action: {
                                        
                                        UIPasteboard.general.string = number
                                    })
                                    
                                    var additioinalButtons: [AdditionalButton] = []
                                    
                                    if let name = detailData.payeeFullName {
                                        
                                        additioinalButtons.append(.init(title: "Изменить", action: { [weak self] in
                                            
                                            self?.action.send(PaymentsSuccessAction.Payment(source: .change(operationId: detailData.paymentOperationDetailId.description,transferNumber: number, name: name)))
                                        }))
                                    }
                                    
                                    let amountValue = detailData.payerAmount - detailData.payerFee
                                    if let amount = model.amountFormatted(amount: amountValue, currencyCode: detailData.payerCurrency, style: .fraction) {
                                        additioinalButtons.append(.init(title: "Вернуть", action: { [weak self] in
                                            
                                            self?.action.send(PaymentsSuccessAction.Payment(source: .return(operationId: detailData.paymentOperationDetailId.description, transferNumber: number, amount: amount, productId: detailData.payerCardId?.description ?? detailData.payerAccountId.description)))
                                        }))
                                    }
                                    
                                    self.additioinalButtons = additioinalButtons
                                }
                                
                            default: break
                            }
                            
                            handleDetailResponse(mode, payload: payload, documentStatus: documentStatus)
                        }
                          
                    case let .failure(error):
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "ModelAction.Operation.Detail.Response error: \(error)")
                    }
                    
                case let payload as ModelAction.PaymentTemplate.Save.Complete:
                    
                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон", isSelected: true) { [weak self] in
                        
                        self?.model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [payload.paymentTemplateId]))
                    }
                    
                    optionButtons[0] = templateButton
                    
                case _ as ModelAction.PaymentTemplate.Delete.Complete:
                    
                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон") { [weak self] in
                        
                        guard let self = self else { return }
                        //TODO: create switch for template name
                        self.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId))
                    }
                    
                    optionButtons[0] = templateButton
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsSuccessAction.OptionButton.Details.Tap:
                    
                    self.sheet = .init(type: .detailInfo(payload.viewModel))
                    
                case let payload as PaymentsSuccessAction.Payment:
                    Task {
                        
                        do {
                            
                            let paymentsViewModel = try await PaymentsViewModel(source: payload.source, model: model) { [weak self] in
                                    
                                self?.fullScreenSheet = nil
                            }
                            
                            await MainActor.run {
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                    
                                    self.fullScreenSheet = .init(type: .abroad(paymentsViewModel))
                                }
                            }
                            
                        } catch {
                            
                            await MainActor.run {
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {

                                    self.alert = .init(title: "Error", message: "Unable create PaymentsViewModel for source: \(payload.source) with error: \(error.localizedDescription)", primary: .init(type: .cancel, title: "Ok", action: {}))
                                }
                            }
                            
                            LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for source: \(payload.source) with error: \(error.localizedDescription)")
                        }
                    }
                    
                default:
                    break
                }
                
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
        let action: () -> Void
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
        
        case template
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
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .normal, .meToMe:
                
                guard let templateButton = optionButton(mode, type: .template, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail),
                      let documentButton = optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail),
                      let detailButton = optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail) else {
                    return []
                }
                
                return [templateButton,
                        documentButton,
                        detailButton]
            case .makePaymentToDeposite:
                
                guard let documentButton = optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail),
                      let detailButton = optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail) else {
                    return []
                }
                
                return [documentButton,
                        detailButton]

            case .closeDeposit, .closeAccount:
                
                guard let documentButton = optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail),
                      let detailButton = optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail) else {
                    return []
                }
                
                return [documentButton,
                        detailButton]
                
            case .closeAccountEmpty:
                
                guard let documentButton = optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail) else {
                    return []
                }
                
                return [documentButton]
            }
            
        case .inProgress:
            
            switch mode {
            case .closeAccount, .closeAccountEmpty:
                return .init()
                
            case .meToMe, .normal:
                
                guard let templateButton = optionButton(mode, type: .template, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail),
                      let detailButton = optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail) else {
                    return []
                }
                
                return [templateButton,
                        detailButton]
            case .makePaymentToDeposite, .closeDeposit:
                guard let detailButton = optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail) else {
                    return []
                }
                
                return [detailButton]
            }
            
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .closeAccount, .closeAccountEmpty:
                return .init()
                
            case .meToMe, .makePaymentToDeposite, .closeDeposit:
                
                guard let detailButton = optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId, operationDetail: operationDetail) else {
                    return []
                }
                
                return [detailButton]
            }
        }
    }
    
    private func optionButton(_ mode: Mode, type: OptionButtonType, paymentOperationDetailId: Int = 0, operationDetail: OperationDetailData? = nil) -> PaymentsSuccessOptionButtonView.ViewModel? {
        
        switch type {
        case .template:
            
            guard let operationDetail = operationDetail else {
                return nil
            }
            
            return .init(icon: .ic24Star, title: "Шаблон") { [weak self] in
                
                switch operationDetail.transferEnum {
                case .sfp:
                    self?.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: operationDetail.payeeFullName ?? "Перевод СБП", paymentOperationDetailId: paymentOperationDetailId))
                    
                default:
                    self?.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId))
                }
            }
            
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
