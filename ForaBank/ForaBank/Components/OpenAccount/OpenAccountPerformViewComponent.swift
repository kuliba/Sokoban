//
//  OpenAccountPerformViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.06.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension OpenAccountPerformView {

    class ViewModel: ObservableObject, Identifiable {

        let action: PassthroughSubject<Action, Never> = .init()

        @Published var confirmCode: String
        @Published var currency: Currency
        @Published var prepareData: OpenAccountPrepareViewModel
        @Published var item: OpenAccountItemViewModel
        @Published var operationType: OpenAccountPerformType
        @Published var alert: Alert.ViewModel?

        let spinnerIcon: Image

        private let model: Model
        private let style: OpenAccountViewModel.Style
        private let closeAction: () -> Void

        private var bindings = Set<AnyCancellable>()

        var currencyTitle: String {

            switch item.currencyType {
            case .RUB: return "счет"
            default:
                return "валютный счет"
            }
        }

        var infoTitle: String {
            
            if item.header.isAccountOpened == true {
                
                return "Счет добавлен в “Мои продукты” на главном экране. Все детали и документацию вы можете найти в профиле продукта"
            }

            return "Откройте \(currencyTitle) в один клик и проводите банковские операции без ограничений"
        }
        
        private var openAccountTitle: String {
            "\(item.currencyType.rawValue) счет открыт "
        }
        
        private var currentOperationType: OpenAccountPerformType {
            
            if item.isAccountOpen {
                return .opened
            }
            
            return .open
        }

        lazy var agreement: AgreementView.ViewModel = makeAgreement()
        lazy var confirm: ConfirmView.ViewModel = makeConfirm()
        lazy var button: OpenAccountButtonView.ViewModel = makeButton()

        init(model: Model,
             item: OpenAccountItemViewModel,
             spinnerIcon: Image = .init("Logo Fora Bank"),
             currency: Currency,
             style: OpenAccountViewModel.Style,
             closeAction: @escaping () -> Void = {}) {

            self.model = model
            self.item = item
            self.spinnerIcon = spinnerIcon
            self.currency = currency
            self.style = style
            self.closeAction = closeAction
            self.operationType = item.isAccountOpen ? .opened : .open

            prepareData = .init()
            self.confirmCode = ""

            bind()
        }

        private func bind() {

            // MARK: - Model

            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in

                    switch action {
                    case let payload as ModelAction.Account.PrepareOpenAccount.Response:

                        switch payload {
                        case let .complete(data):

                            prepareData = OpenAccountPrepareViewModel.reduce(data: data)
                            operationType = .edit

                        case let .failed(error: error):
                            
                            operationType = currentOperationType
                            self.action.send(OpenAccountPerformAction.Alert.Error(error: error))
                        }

                    case let payload as ModelAction.Account.MakeOpenAccount.Response:

                        switch payload {
                        case let .complete(data):

                            operationType = .opened

                            item.isAccountOpen = true
                            item.header.isAccountOpened = true
                            item.header.title = openAccountTitle

                            let accountNumber = data.accountNumber

                            guard accountNumber.isEmpty == false else {
                                return
                            }

                            item.card.numberCard = accountNumber

                        case let .failed(error: error):
                            
                            let rawValue = model.accountRawResponse(error: error)
                            
                            switch rawValue {
                            case .exhaust:
                                
                                confirm.confirmCode = ""
                                confirm.enterCode = ""
                                confirm.textFieldToolbar.text = ""
                                
                            default:
                                break
                            }
                            
                            confirm.isResendCode = true
                            
                            handleRawResponse(error: error)
                            self.action.send(OpenAccountPerformAction.Alert.Error(error: error))
                        }

                    case let payload as ModelAction.Auth.VerificationCode.PushRecieved:
                        
                        confirm.confirmCode = payload.code
                        confirm.enterCode = payload.code
                        confirm.textFieldToolbar.text = payload.code
                        
                        operationType = .edit

                    default:
                        break
                    }
                }.store(in: &bindings)

            // MARK: - ViewModel

            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in

                    switch action {
                    case _ as OpenAccountPerformAction.Button.Tapped:

                        if item.header.isAccountOpened == true {
                            self.action.send(OpenAccountPerformAction.ResetData())
                        }

                        operationType = .opening
                        model.action.send(ModelAction.Account.PrepareOpenAccount.Request())

                    case _ as OpenAccountPerformAction.Button.Confirm:

                        operationType = .confirm
                        
                        let verificationCode = confirm.enterCode.isEmpty == true ? confirmCode : confirm.enterCode
                        
                        model.action.send(ModelAction.Account.MakeOpenAccount.Request(
                            verificationCode: verificationCode,
                            currency: currency,
                            currencyCode: item.currencyCode)
                        )
                        
                    case _ as OpenAccountPerformAction.Button.Close:
                        closeAction()

                    case _ as OpenAccountPerformAction.Button.Terms:

                        openLinkURL(item.conditionLinkURL)

                    case _ as OpenAccountPerformAction.Button.Rates:

                        if let ratesLinkURL = item.ratesLinkURL {
                            openLinkURL(ratesLinkURL)
                        }

                    case let payload as OpenAccountPerformAction.Alert.Error:
                        makeAlert(error: payload.error)

                    case _ as OpenAccountPerformAction.ResetData:

                        item.header.isAccountOpened = false
                        item.card.numberCard = "XXXXXXXXXXXXXXXX"
                        confirmCode = ""

                    default:
                        break
                    }
                }.store(in: &bindings)

            confirm.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in

                    switch action {

                    case _ as ConfirmViewModelAction.Button.Done:
                        endEditing()

                    case _ as ConfirmViewModelAction.Button.Close:
                        endEditing()

                    case _ as ConfirmViewModelAction.Button.ResendCode:
                        
                        model.action.send(ModelAction.Account.PrepareOpenAccount.Request())

                    default:
                        break
                    }
                }.store(in: &bindings)

            $prepareData
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] prepareData in

                    confirm.prepareData = prepareData

                }.store(in: &bindings)

            $operationType
                .combineLatest($currency)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in

                    button.update(operationType: data.0, currency: data.1)

                }.store(in: &bindings)

            item.$isAccountOpen
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isAccountOpen in

                    operationType = isAccountOpen ? .opened : .open

                }.store(in: &bindings)
        }

        private func openLinkURL(_ linkURL: String) {

            guard let url = URL(string: linkURL) else {
                return
            }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        private func makeButton() -> OpenAccountButtonView.ViewModel {
            
            .init(currency: currency, operationType: operationType, style: style) { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                switch self.operationType {
                case .open:
                    self.action.send(OpenAccountPerformAction.Button.Tapped())
                case .opened:
                    
                    switch self.style {
                    case .openAccount:
                        self.action.send(OpenAccountPerformAction.Button.Tapped())
                    case .currencyWallet:
                        self.action.send(OpenAccountPerformAction.Button.Close())
                    }
                case .edit:
                    self.action.send(OpenAccountPerformAction.Button.Confirm())
                default:
                    break
                }
            }
        }
        
        private func makeAgreement() -> AgreementView.ViewModel {
            
            let termsAction: () -> Void = { [weak self] in
                self?.action.send(OpenAccountPerformAction.Button.Terms())
            }

            let ratesAction: () -> Void = { [weak self] in
                self?.action.send(OpenAccountPerformAction.Button.Rates())
            }

            return .init(icon: .init("Checkbox Active"),
                         termsButton: .init(action: termsAction),
                         ratesButton: .init(action: ratesAction)
            )
        }
        
        private func makeConfirm() -> ConfirmView.ViewModel {
            .init(prepareData: prepareData, confirmCode: confirmCode)
        }

        private func makeAlert(error: Model.ProductsListError) {

            var messageError: String?

            switch error {
            case let .emptyData(message: message):
                messageError = message
            case let .statusError(status: _, message: message):
                messageError = message
            case let .serverCommandError(error: error):
                messageError = error
            default:
                break
            }

            guard let messageError = messageError else {
                return
            }

            alert = .init(
                title: "Ошибка",
                message: messageError,
                primary: .init(type: .default, title: "Ok") { [weak self] in
                    self?.alert = nil
                })
        }

        private func endEditing() {

            operationType = .edit
            UIApplication.shared.endEditing()
        }
        
        private func handleRawResponse(error: Model.ProductsListError) {
            
            let rawValue = model.accountRawResponse(error: error)
            
            switch rawValue {
            case .incorrect:
                operationType = .edit
            case .exhaust:
                operationType = currentOperationType
                self.action.send(OpenAccountPerformAction.ResetData())
            case .none:
                break
            }
        }
    }
}

// MARK: - ViewModel

struct OpenAccountPrepareViewModel {

    var otpLength: Int
    var otpResendTime: Int
    var resendOTPCount: Int

    init(otpLength: Int = 0, otpResendTime: Int = 0, resendOTPCount: Int = 0) {

        self.otpLength = otpLength
        self.otpResendTime = otpResendTime
        self.resendOTPCount = resendOTPCount
    }
}

// MARK: - Reducer

extension OpenAccountPrepareViewModel {

    static func reduce(data: OpenAccountPrepareData) -> OpenAccountPrepareViewModel {

        return .init(otpLength: data.otpLength, otpResendTime: data.otpResendTime, resendOTPCount: data.resendOTPCount)
    }
}

// MARK: - RawResponse

enum OpenAccountRawResponse: RawRepresentable {
    
    case incorrect
    case exhaust
    case none
    
    var rawValue: String {
        switch self {
        case .incorrect:
            return "Вы исчерпали все попытки"
        case .exhaust:
            return "Введен некорректный код. Попробуйте еще раз"
        case .none:
            return ""
        }
    }
    
    init?(rawValue: String) {
        
        if rawValue.contains("исчерпали") {
            self = .exhaust
            return
        }
        
        self = .incorrect
    }
}

// MARK: - View

struct OpenAccountPerformView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            switch viewModel.operationType {
            case .open, .opened:

                Text(viewModel.infoTitle)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsBlack)
                    .frame(height: 56, alignment: .top)
                    .padding(.trailing)

                OpenAccountButtonView(viewModel: viewModel.button)
                    .frame(height: 48)

                AgreementView(viewModel: viewModel.agreement)
                    .padding([.top, .bottom], 8)

            case .opening:

                SpinnerRefreshView(icon: viewModel.spinnerIcon)
                    .padding(.top)

            case .edit:

                ConfirmView(viewModel: viewModel.confirm)
                    .padding(.top)

                if viewModel.confirm.enterCode.isEmpty == false {

                    OpenAccountButtonView(viewModel: viewModel.button)
                        .frame(height: 48)
                        .padding(.top, 40)
                }
                
                Spacer()

            case .confirm:

                ConfirmView(viewModel: viewModel.confirm)
                    .padding(.top, 4)

                HStack(alignment: .center) {
    
                    Spacer()
                    
                    SpinnerRefreshView(icon: viewModel.spinnerIcon)
                        .padding(.top, 36)
                    
                    Spacer()
                }
            }
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(with: alert)
        }
        .frame(height: 190)
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Action

enum OpenAccountPerformAction {

    enum Button {

        struct Tapped: Action {}
        struct Confirm: Action {}
        struct Terms: Action {}
        struct Rates: Action {}
        struct Close: Action {}
    }

    struct PushRecieved: Action {

        let code: String
    }

    enum Alert {

        struct Error: Action {

            let error: Model.ProductsListError
        }
    }

    struct ResetData: Action {}
}

// MARK: - PerformType

enum OpenAccountPerformType: Equatable {

    case open
    case opening
    case opened
    case edit
    case confirm
}

// MARK: - Previews

struct OpenAccountPerformViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        Group {

            OpenAccountPerformView(
                viewModel: .init(
                    model: .productsMock,
                    item: .empty,
                    currency: .init(description: "USD"),
                    style: .openAccount))

            OpenAccountPerformView(
                viewModel: .init(
                    model: .productsMock,
                    item: .empty,
                    currency: .init(description: "EUR"),
                    style: .openAccount))
        }
        .frame(height: 220)
        .padding(.top)
        .previewLayout(.sizeThatFits)
    }
}
