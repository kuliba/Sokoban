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
    @Published var sheet: Sheet?
    
    let id = UUID()
    let title: String?
    let warningTitle: String?
    let amount: String?
    let iconType: IconTypeViewModel
    let service: ServiceViewModel?
    let options: [OptionViewModel]?
    let logo: LogoIconViewModel?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    private lazy var repeatAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Repeat())
    }
    
    private lazy var closeAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Close())
    }
    
    init(_ model: Model, title: String? = nil, warningTitle: String? = nil, amount: String? = nil, iconType: IconTypeViewModel, service: ServiceViewModel? = nil, options: [OptionViewModel]? = nil, logo: LogoIconViewModel? = nil, repeatButton: ButtonSimpleView.ViewModel? = nil, actionButton: ButtonSimpleView.ViewModel, optionButtons: [PaymentsSuccessOptionButtonViewModel]) {
        
        self.model = model
        self.title = title
        self.warningTitle = warningTitle
        self.amount = amount
        self.iconType = iconType
        self.service = service
        self.options = options
        self.logo = logo
        self.repeatButton = repeatButton
        self.actionButton = actionButton
        self.optionButtons = optionButtons
    }
    
    convenience init(_ model: Model, closeAction: @escaping () -> Void) {
        
        self.init(model, iconType: .success, actionButton: .init(title: "На главный", style: .red, action: closeAction), optionButtons: [])
    }
    
    convenience init(_ model: Model, paymentSuccess: Payments.Success) {
        
        let product = model.allProducts.first(where: { $0.id == paymentSuccess.productId })
        let amount = model.amountFormatted(amount: paymentSuccess.amount, currencyCode: product?.currency, style: .normal)
        
        self.init(model, documentStatus: paymentSuccess.status, mode: .normal, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])

        updateButtons(
            .normal,
            documentStatus: paymentSuccess.status,
            paymentOperationDetailId: paymentSuccess.operationDetailId)
        
        bind(.normal, paymentOperationDetailId: paymentSuccess.operationDetailId)
    }

    convenience init?(_ model: Model, mode: Mode = .normal, transferData: TransferResponseData) {
        
        guard let documentStatus = transferData.documentStatus else {
            return nil
        }
        
        let amount = Self.amountFormatted(model, amount: transferData.debitAmount ?? 0, currencyCode: transferData.currencyPayer?.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])

        updateButtons(
            mode,
            documentStatus: documentStatus,
            paymentOperationDetailId: transferData.paymentOperationDetailId)
        
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId)
    }
    
    convenience init?(_ model: Model, mode: Mode = .normal, productIdFrom: ProductData.ID?, productIdTo: ProductData.ID?, transferData: TransferResponseData) {
        
        guard let documentStatus = transferData.documentStatus else {
            return nil
        }
        
        let debitAmount = transferData.debitAmount ?? 0
        let amount = Self.amountFormatted(model, amount: debitAmount, currencyCode: transferData.currencyPayer?.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])

        updateButtons(
            mode,
            documentStatus: documentStatus,
            paymentOperationDetailId: transferData.paymentOperationDetailId)
        
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId)
        bind(mode, paymentOperationDetailId: transferData.paymentOperationDetailId, amount: debitAmount, productIdFrom: productIdFrom, productIdTo: productIdTo)
    }

    convenience init?(_ model: Model, mode: Mode = .normal, currency: Currency, balance: Double, transferData: CloseProductTransferData) {
        
        let documentStatus: TransferResponseBaseData.DocumentStatus? = .init(rawValue: transferData.documentStatus)
        
        guard let documentStatus = documentStatus,
              let paymentOperationDetailId = transferData.paymentOperationDetailId else {
            return nil
        }

        let amount = Self.amountFormatted(
            model,
            amount: balance,
            currencyCode: currency.description)
        
        self.init(model, documentStatus: documentStatus, mode: mode, amount: amount, actionButton: .init(title: "На главный", style: .red, action: {}), optionButtons: [])
        
        updateButtons(
            mode,
            documentStatus: documentStatus,
            paymentOperationDetailId: paymentOperationDetailId)
        
        bind(mode, paymentOperationDetailId: paymentOperationDetailId)
    }
    
    convenience init(_ model: Model, documentStatus: TransferResponseBaseData.DocumentStatus, mode: Mode, amount: String?, actionButton: ButtonSimpleView.ViewModel, optionButtons: [PaymentsSuccessOptionButtonViewModel]) {
        
        let title = Self.title(mode, documentStatus: documentStatus)
        
        switch documentStatus {
        case .complete:
            
            self.init(model, title: title, amount: amount, iconType: .success, actionButton: actionButton, optionButtons: [])
            
        case .inProgress:
            
            self.init(model, title: title, amount: amount, iconType: .accepted, actionButton: actionButton, optionButtons: [])
            
        case .rejected, .unknown:
            
            self.init(model, title: title, amount: amount, iconType: .error, actionButton: actionButton, optionButtons: [])
            
            repeatButton = .init(title: "Повторить", style: .gray, action: repeatAction)
        }
    }

    private func bind(_ mode: Mode, paymentOperationDetailId: Int) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {

                case let payload as ModelAction.Operation.Detail.Response:
                    handleDetailResponse(mode, payload: payload)
                    
                case let payload as ModelAction.PaymentTemplate.Save.Complete:

                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон", isSelected: true) { [weak self] in

                        self?.model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [payload.paymentTemplateId]))
                    }

                    optionButtons[0] = templateButton

                case _ as ModelAction.PaymentTemplate.Delete.Complete:

                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон") { [weak self] in

                        guard let self = self else { return }
                        self.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId))
                    }

                    optionButtons[0] = templateButton
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ mode: Mode, paymentOperationDetailId: Int, amount: Double, productIdFrom: ProductData.ID?, productIdTo: ProductData.ID?) {
        
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
                    
                    handleDetailResponse(mode, payload: payload)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func updateButtons(_ mode: Mode, documentStatus: TransferResponseBaseData.DocumentStatus, paymentOperationDetailId: Int) {
        
        actionButton = .init(title: "На главный", style: .red, action: closeAction)
        optionButtons = makeOptionButtons(mode, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId)
    }
}

extension PaymentsSuccessViewModel {
    
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
            case .normal, .meToMe, .closeDeposit, .closeAccount: return "Успешный перевод"
            case .closeAccountEmpty: return "Счет успешно закрыт"
            }
            
        case .inProgress:
            
            switch mode {
            case .normal, .closeAccount, .closeDeposit, .closeAccountEmpty: return .init()
            case .meToMe: return "Операция в обработке!"
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .closeDeposit, .closeAccount: return .init()
            case .meToMe: return "Операция неуспешна!"
            case .closeAccountEmpty: return "Отказ"
            }
        }
    }
    
    static func amountFormatted(_ model: Model, amount: Double, currencyCode: String?) -> String? {
        
        let amountFormatted = model.amountFormatted(amount: amount, currencyCode: currencyCode, style: .fraction)
        let amount = amount == 0 ? nil : amountFormatted
        
        return amount
    }
    
    private func makeOptionButtons(_ mode: Mode, documentStatus: TransferResponseBaseData.DocumentStatus, paymentOperationDetailId: Int) -> [PaymentsSuccessOptionButtonViewModel] {
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .normal, .meToMe:
                
                return [optionButton(mode, type: .template, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeDeposit, .closeAccount:
                
                return [optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeAccountEmpty:
                
                return [optionButton(mode, type: .document, paymentOperationDetailId: paymentOperationDetailId)]
            }
            
        case .inProgress:
            
            switch mode {
            case .normal, .closeDeposit, .closeAccount, .closeAccountEmpty:
                return .init()

            case .meToMe:
                
                return [optionButton(mode, type: .template, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId)]
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .closeDeposit, .closeAccount, .closeAccountEmpty:
                return .init()
                
            case .meToMe:
                
                return [optionButton(mode, type: .details, paymentOperationDetailId: paymentOperationDetailId)]
            }
        }
    }

    private func optionButton(_ mode: Mode, type: OptionButtonType, paymentOperationDetailId: Int = 0) -> PaymentsSuccessOptionButtonView.ViewModel {
        
        switch type {
        case .template:
            
            return .init(icon: .ic24Star, title: "Шаблон") { [weak self] in
                
                self?.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId))
            }
            
        case .document:
            
            return .init(icon: .ic24File, title: "Документ") { [weak self] in
                
                guard let self = self else {
                    return
                }
            
                switch mode {
                case .normal, .meToMe, .closeDeposit:
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .operation(paymentOperationDetailId: paymentOperationDetailId, printFormType: .internal), model: self.model)
                    
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
                
                self.model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentOperationDetailId)))
            }
        }
    }

    private func handleDetailResponse(_ mode: Mode, payload: ModelAction.Operation.Detail.Response) {
        
        switch payload.result {
        case let .success(detailData):
            
            switch mode {
            case .closeDeposit:
                
                let viewModel: OperationDetailInfoViewModel = .init(model: model, operation: detailData) { [weak self] in
                    
                    guard let self = self else {
                        return
                    }
                    
                    self.sheet = nil
                }
                
                if sheet == nil {
                    sheet = .init(type: .detailInfo(viewModel))
                }
                
            default:
                
                let viewModel: OperationDetailInfoViewModel = .init(model: model, operation: detailData) { [weak self] in
                    
                    guard let self = self else {
                        return
                    }
                    
                    self.sheet = nil
                }
                
                if sheet == nil {
                    sheet = .init(type: .detailInfo(viewModel))
                }
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
    
    enum OptionButton {
        
        enum Template {
            
            struct Tap: Action {}
        }
        
        enum Document {
            
            struct Tap: Action {}
        }
        
        enum details {
            
            struct Tap: Action {}
        }
    }
}

extension PaymentsSuccessViewModel {
    
    func makeDetailData(amount: Double, productFrom: ProductData, productTo: ProductData, paymentOperationDetailId: Int, transferEnum: OperationDetailData.TransferEnum) -> OperationDetailData {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let date = dateFormatter.string(from: Date())
        
        return .init(oktmo: nil, account: nil, accountTitle: nil, amount: amount, billDate: nil, billNumber: nil, claimId: UUID().uuidString, comment: "Перевод с конверсией денежных средств между счетами Клиента", countryName: nil, currencyAmount: productFrom.currency, dateForDetail: date, division: nil, driverLicense: nil, externalTransferType: nil, isForaBank: nil, isTrafficPoliceService: false, memberId: nil, operation: "Перевод денежных средств между счетами Клиента с конверсией по курсу банка", payeeAccountId: productTo.id, payeeAccountNumber: productTo.accountNumber, payeeAmount: productTo.balanceValue, payeeBankBIC: nil, payeeBankCorrAccount: nil, payeeBankName: productTo.displayName, payeeCardId: nil, payeeCardNumber: productTo.number, payeeCurrency: productTo.currency, payeeFirstName: nil, payeeFullName: productTo.productName, payeeINN: nil, payeeKPP: nil, payeeMiddleName: nil, payeePhone: nil, payeeSurName: nil, payerAccountId: productFrom.id, payerAccountNumber: productFrom.accountNumber ?? "", payerAddress: "", payerAmount: amount, payerCardId: productFrom.id, payerCardNumber: productFrom.number, payerCurrency: productFrom.currency, payerDocument: nil, payerFee: 0, payerFirstName: productFrom.displayName, payerFullName: productFrom.productName, payerINN: nil, payerMiddleName: productFrom.displayName, payerPhone: nil, payerSurName: nil, paymentOperationDetailId: paymentOperationDetailId, paymentTemplateId: nil, period: nil, printFormType: .internal, provider: nil, puref: nil, regCert: nil, requestDate: date, responseDate: date, returned: nil, transferDate: date, transferEnum: transferEnum, transferNumber: nil, transferReference: nil, cursivePayerAmount: nil, cursivePayeeAmount: nil, cursiveAmount: nil, serviceSelect: nil, serviceName: nil, merchantSubName: nil, merchantIcon: nil, operationStatus: nil, shopLink: nil, payeeCheckAccount: nil, depositNumber: nil, depositDateOpen: nil, currencyRate: nil, mcc: nil, printData: nil)
    }
}
