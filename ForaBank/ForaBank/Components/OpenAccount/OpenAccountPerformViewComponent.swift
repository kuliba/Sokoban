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
        @Published var currencyName: String
        @Published var prepareData: OpenAccountPrepareViewModel
        @Published var item: OpenAccountItemViewModel
        @Published var operationType: OpenAccountPerformType
        @Published var alert: Alert.ViewModel?

        let spinnerIcon: Image

        private let model: Model
        private var bindings = Set<AnyCancellable>()

        var currencyTitle: String {

            switch item.currencyType {
            case .RUB: return "счет"
            default:
                return "валютный счет"
            }
        }

        var infoTitle: String {

            switch operationType {
            case .opened:
                return "Счет добавлен в “Мои продукты” на главном экране. Все детали и документацию вы можете найти в профиле продукта"
            default:
                return "Откройте \(currencyTitle) в один клик и проводите банковские операции без ограничений"
            }
        }

        lazy var agreement: AgreementView.ViewModel = {

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
        }()

        lazy var confirm: ConfirmView.ViewModel = .init(prepareData: prepareData, confirmCode: confirmCode)

        lazy var button: OpenAccountButtonView.ViewModel = .init(currencyName: currencyName, confirmCode: confirmCode, operationType: operationType) { [weak self] in

            guard let self = self else {
                return
            }

            switch self.operationType {
            case .open, .opened:
                self.action.send(OpenAccountPerformAction.Button.Tapped())
            case .edit:
                self.action.send(OpenAccountPerformAction.Button.Confirm())
            default:
                break
            }
        }

        init(model: Model,
             item: OpenAccountItemViewModel,
             spinnerIcon: Image = .init("Logo Fora Bank"),
             currencyName: String) {

            self.model = model
            self.item = item
            self.spinnerIcon = spinnerIcon
            self.currencyName = currencyName
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
                            
                            self.action.send(OpenAccountPerformAction.Alert.Error(error: error))
                        }

                    case let payload as ModelAction.Account.MakeOpenAccount.Response:

                        switch payload {
                        case let .complete(data):

                            operationType = .opened

                            item.header.isAccountOpened = true
                            item.header.title = "\(item.header.title) открыт "

                            let accountNumber = data.accountNumber

                            guard accountNumber.isEmpty == false else {
                                return
                            }

                            item.card.numberCard = accountNumber

                        case let .failed(error: error):
                            
                            handleRawResponse(error: error)
                            self.action.send(OpenAccountPerformAction.Alert.Error(error: error))
                        }

                    case let payload as ModelAction.Auth.VerificationCode.PushRecieved:

                        confirmCode = payload.code

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
                        model.action.send(ModelAction.Account.MakeOpenAccount.Request(
                            verificationCode: confirmCode,
                            currencyName: currencyName,
                            currencyCode: item.currencyCode)
                        )

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

                        confirmCode = confirm.enterCode
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

            $confirmCode
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] confirmCode in

                    confirm.confirmCode = confirmCode

                }.store(in: &bindings)

            $operationType
                .combineLatest($currencyName, $confirmCode)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in

                    button.update(
                        operationType: data.0,
                        currencyName: data.1,
                        confirmCode: data.2)

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

            UIApplication.shared.endEditing()
        }
        
        private func handleRawResponse(error: Model.ProductsListError) {
            
            var messageError = ""
            
            switch error {
            case .emptyData(message: let message):
                
                guard let message = message else { return }
                messageError = message
                
            case let .statusError(_, message: message):
                
                guard let message = message else { return }
                messageError = message

            case .serverCommandError(error: let error):
                messageError = error
            default:
                break
            }
            
            guard let rawValue = OpenAccountRawResponse(rawValue: messageError) else {
                return
            }
            
            switch rawValue {
            case .incorrect:
                operationType = .edit
            case .exhaust:
                operationType = .open
                self.action.send(OpenAccountPerformAction.ResetData())
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
    
    var rawValue: String {
        switch self {
        case .incorrect:
            return "Вы исчерпали все попытки"
        case .exhaust:
            return "Введен некорректный код. Попробуйте еще раз"
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

        VStack {

            switch viewModel.operationType {
            case .open, .opened:

                HStack {

                    Text(viewModel.infoTitle)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsBlack)

                    Spacer()

                }.padding(.bottom, 20)

                OpenAccountButtonView(viewModel: viewModel.button)
                    .frame(height: 48)

                HStack {

                    AgreementView(viewModel: viewModel.agreement)

                    Spacer()

                }.padding(.top, 10)

            case .opening:

                SpinnerRefreshView(icon: viewModel.spinnerIcon)
                    .padding(.top, 56)

            case .edit:

                ConfirmView(viewModel: viewModel.confirm)
                    .padding(.top, 4)

                if viewModel.confirmCode.isEmpty == false {

                    OpenAccountButtonView(viewModel: viewModel.button)
                        .frame(height: 48)
                        .padding(.top, 46)
                }

            case .confirm:

                ConfirmView(viewModel: viewModel.confirm)
                    .padding(.top, 4)

                SpinnerRefreshView(icon: viewModel.spinnerIcon)
                    .padding(.top, 46)
            }

            Spacer()
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(with: alert)
        }
        .padding([.leading, .trailing, .bottom], 20)
        .padding(.top, 12)
    }
}

// MARK: - Action

enum OpenAccountPerformAction {

    enum Button {

        struct Tapped: Action {}
        struct Confirm: Action {}
        struct Terms: Action {}
        struct Rates: Action {}
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
                    currencyName: "USD"))

            OpenAccountPerformView(
                viewModel: .init(
                    model: .productsMock,
                    item: .empty,
                    currencyName: "USD"))
        }
        .frame(height: 220)
        .padding(.top)
        .previewLayout(.sizeThatFits)
    }
}
