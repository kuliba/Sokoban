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
    private let mode: Mode
    private let state: State
    
    private var bindings = Set<AnyCancellable>()

    private lazy var repeatAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Repeat())
    }
    
    private lazy var closeAction: () -> Void = { [weak self] in
        self?.action.send(PaymentsSuccessAction.Button.Close())
    }
    
    init(_ model: Model, mode: Mode = .normal, state: State, title: String? = nil, warningTitle: String? = nil, amount: String? = nil, iconType: IconTypeViewModel, service: ServiceViewModel? = nil, options: [OptionViewModel]? = nil, logo: LogoIconViewModel? = nil, repeatButton: ButtonSimpleView.ViewModel? = nil, actionButton: ButtonSimpleView.ViewModel, optionButtons: [PaymentsSuccessOptionButtonViewModel]) {
        
        self.model = model
        self.mode = mode
        self.state = state
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
    
    convenience init(_ model: Model, state: State, closeAction: @escaping () -> Void) {
        
        self.init(model, state: state, iconType: .success, actionButton: .init(title: "На главную", style: .red, action: closeAction), optionButtons: [])
    }
    
    convenience init(_ model: Model, iconType: IconTypeViewModel, paymentSuccess: Payments.Success, dismissAction: @escaping () -> Void) {
        
        let amount = model.amountFormatted(amount: paymentSuccess.amount, currencyCode: nil, style: .normal)
        let image = paymentSuccess.icon?.image ?? .ic40Sbp
        
        self.init(model, mode: .normal, state: .success(.complete, 0), title: paymentSuccess.status.description, amount: amount, iconType: .success, logo: .init(title: "сбп", image: image), actionButton: .init(title: "На главную", style: .red, action: dismissAction), optionButtons: [])
    }
    
    convenience init(_ model: Model, mode: Mode, state: State, responseData: TransferResponseData) {
        
        let amountFormatted = model.amountFormatted(amount: responseData.debitAmount ?? 0, currencyCode: responseData.currencyPayer?.description, style: .fraction)
        
        let amount = responseData.debitAmount == 0 ? nil : amountFormatted
        let initialButton: ButtonSimpleView.ViewModel = .init(title: "На главную", style: .red, action: {})
        
        switch state {
        case let .success(status, paymentOperationDetailId):
            
            let title = Self.title(mode, documentStatus: status)
            
            switch status {
            case .complete:
                
                self.init(model, mode: mode, state: state, title: title, amount: amount, iconType: .success, actionButton: initialButton, optionButtons: [])
                
            case .inProgress:
                
                self.init(model, mode: mode, state: state, title: title, amount: amount, iconType: .accepted, actionButton: initialButton, optionButtons: [])
                
            case .rejected, .unknown:
                
                self.init(model, mode: mode, state: state, title: title, amount: amount, iconType: .error, actionButton: initialButton, optionButtons: [])
                
                repeatButton = .init(title: "Повторить", style: .gray, action: repeatAction)
            }
            
            updateWith(status, paymentOperationDetailId: paymentOperationDetailId)
            
        case .failed:

            self.init(model, mode: mode, state: state, title: "Операция неуспешна!", amount: amount, iconType: .error, actionButton: initialButton, optionButtons: [])
            
            updateWith(responseData.paymentOperationDetailId)
        }
        
        bind()
    }

    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ModelAction.Payment.OperationDetailByPaymentId.Response:
                    handleDetailResponse(payload)
                    
                case let payload as ModelAction.PaymentTemplate.Save.Complete:

                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон", isSelected: true) { [weak self] in

                        self?.model.action.send(ModelAction.PaymentTemplate.Delete.Requested(paymentTemplateIdList: [payload.paymentTemplateId]))
                    }

                    optionButtons[0] = templateButton

                case _ as ModelAction.PaymentTemplate.Delete.Complete:

                    let templateButton: PaymentsSuccessOptionButtonView.ViewModel = .init(icon: .ic24Star, title: "Шаблон") { [weak self] in

                        guard let self = self else { return }

                        switch self.state {
                        case let .success(_, paymentOperationDetailId):

                            self.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId))

                        case .failed:
                            break
                        }
                    }

                    optionButtons[0] = templateButton
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func updateWith(_ documentStatus: TransferResponseBaseData.DocumentStatus, paymentOperationDetailId: Int) {
        
        actionButton = .init(title: "На главную", style: .red, action: closeAction)
        optionButtons = makeOptionButtons(documentStatus, paymentOperationDetailId: paymentOperationDetailId)
    }
    
    private func updateWith(_ paymentOperationDetailId: Int) {
        
        actionButton = .init(title: "На главную", style: .red, action: closeAction)
        repeatButton = .init(title: "Повторить", style: .gray, action: repeatAction)
        optionButtons = [optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
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
        case closeAccount
        case closeAccountEmpty(ProductData.ID)
    }
    
    enum State {
        
        case success(TransferResponseBaseData.DocumentStatus, Int)
        case failed(ModelError)
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
            case .normal, .meToMe, .closeAccount: return "Успешный перевод"
            case .closeAccountEmpty: return "Счет успешно закрыт"
            }
            
        case .inProgress:
            
            switch mode {
            case .normal, .closeAccount, .closeAccountEmpty: return .init()
            case .meToMe: return "Операция в обработке!"
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .closeAccount: return .init()
            case .meToMe: return "Операция неуспешна!"
            case .closeAccountEmpty: return "Отказ"
            }
        }
    }
    
    private func makeOptionButtons(_ documentStatus: TransferResponseBaseData.DocumentStatus, paymentOperationDetailId: Int) -> [PaymentsSuccessOptionButtonViewModel] {
        
        switch documentStatus {
        case .complete:
            
            switch mode {
            case .normal, .meToMe:
                
                return [optionButton(.template, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.document, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeAccount:
                
                return [optionButton(.document, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
                
            case .closeAccountEmpty:
                
                return [optionButton(.document, paymentOperationDetailId: paymentOperationDetailId)]
            }
            
        case .inProgress:
            
            switch mode {
            case .normal, .closeAccount, .closeAccountEmpty:
                return .init()

            case .meToMe:
                
                return [optionButton(.template, paymentOperationDetailId: paymentOperationDetailId),
                        optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
            }
            
        case .rejected, .unknown:
            
            switch mode {
            case .normal, .closeAccount, .closeAccountEmpty:
                return .init()
                
            case .meToMe:
                
                return [optionButton(.details, paymentOperationDetailId: paymentOperationDetailId)]
            }
        }
    }

    private func optionButton(_ type: OptionButtonType, paymentOperationDetailId: Int = 0) -> PaymentsSuccessOptionButtonView.ViewModel {
        
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
            
                switch self.mode {
                case .normal, .meToMe, .closeAccount:
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .operation(paymentOperationDetailId: paymentOperationDetailId, printFormType: .internal), model: self.model)
                    
                    self.sheet = .init(type: .printForm(printViewModel))
                    
                case let .closeAccountEmpty(productId):
                    
                    let printViewModel: PrintFormView.ViewModel = .init(type: .closeAccount(id: productId), model: self.model)
                    
                    self.sheet = .init(type: .printForm(printViewModel))
                }
        }

        case .details:
            
            return .init(icon: .ic24Info, title: "Детали") { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                self.model.action.send(ModelAction.Payment.OperationDetailByPaymentId.Request(paymentOperationDetailId: paymentOperationDetailId))
            }
        }
    }
    
    private func handleDetailResponse(_ payload: ModelAction.Payment.OperationDetailByPaymentId.Response) {
        
        switch payload {
        case let .success(detailData):
            
            let viewModel: OperationDetailInfoViewModel = .init(model: model, operation: detailData) { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                self.sheet = nil
            }
            
            if sheet == nil {
                sheet = .init(type: .detailInfo(viewModel))
            }
            
        case .failture:
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
