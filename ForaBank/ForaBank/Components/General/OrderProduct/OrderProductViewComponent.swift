//
//  OrderProductViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 08.12.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension OrderProductView {
    
    class ViewModel: ObservableObject {
        
        @Published var isOrderCompletion: Bool
        @Published var isValidPhoneNumber: Bool
        @Published var isSmsCode: Bool
        @Published var state: State
        @Published var alert: Alert.ViewModel?
        
        let nameTextField: TextFieldView.ViewModel
        let phoneNumber: PhoneNumberViewModel
        let smsCode: SmsCodeViewModel
        let agreeData: AgreeDataViewModel
        let sendButton: SendButtonViewModel
        let notify: NotifyViewModel
        
        let title = "Заполните информацию"
        let detailTitle = "В ближайшее время Вам позвонит\nсотрудник банка для\nподтверждения данных"
        
        private let model: Model
        private let productTariff: Int
        private let productType: Int
        private var bindings = Set<AnyCancellable>()
        
        private var leadID: Int?

        enum State {
            
            case normal
            case loading
            case error
        }
        
        init(_ model: Model, productTariff: Int, productType: Int, isOrderCompletion: Bool, isValidPhoneNumber: Bool, isSmsCode: Bool, state: State, nameTextField: TextFieldView.ViewModel, phoneNumber: PhoneNumberViewModel, smsCode: SmsCodeViewModel, agreeData: AgreeDataViewModel, sendButton: SendButtonViewModel, notify: NotifyViewModel) {
            
            self.model = model
            self.productTariff = productTariff
            self.productType = productType
            self.isOrderCompletion = isOrderCompletion
            self.isValidPhoneNumber = isValidPhoneNumber
            self.isSmsCode = isSmsCode
            self.state = state
            self.nameTextField = nameTextField
            self.phoneNumber = phoneNumber
            self.smsCode = smsCode
            self.agreeData = agreeData
            self.sendButton = sendButton
            self.notify = notify
        }
        
        convenience init(_ model: Model, productData: CatalogProductData) {
            
            let phoneNumber: PhoneNumberViewModel = .init(
                style: .order,
                placeHolder: .phone
            )
            
            self.init(
                model,
                productTariff: productData.tariff,
                productType: productData.productType,
                isOrderCompletion: false,
                isValidPhoneNumber: false,
                isSmsCode: false,
                state: .normal,
                nameTextField: .init(.name),
                phoneNumber: phoneNumber,
                smsCode: .init(.smsCode),
                agreeData: .init(),
                sendButton: .init(),
                notify: .init()
            )
            
            bind()
        }
        
        private func bind() {
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {

                    case let payload as ModelAction.Auth.OrderLead.Response:
                        
                        switch payload {
                        case let .success(leadID: leadID):
                            
                            self.leadID = leadID
                            
                            withAnimation {
                                phoneNumber.isError = false
                            }
                            
                        case let .error(message: message):
                            
                            withAnimation {
                                
                                phoneNumber.isError = true
                                state = .error
                            }
                            
                            makeAlert(message)
                        }
                        
                        state = .normal
                        isSmsCode = true
                        
                    case let payload as ModelAction.Auth.VerifyPhone.Response:
                        
                        switch payload {
                        case .success:
                            
                            withAnimation {
                                
                                smsCode.isError = false
                                isOrderCompletion = true
                            }
                            
                        case let .error(message: message):
                            
                            withAnimation {
                                
                                smsCode.isError = true
                                state = .error
                            }
                            
                            makeAlert(message)
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            model.sessionAgent.sessionState
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] sessionState in

                    switch sessionState {
                    case .inactive, .expired, .failed:
                        checkSessionActive()
                        
                    default:
                        break
                    }

                }.store(in: &bindings)
            
            agreeData.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as OrderProductAction.Agree.Tap:
                        openLinkURL()
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)

            sendButton.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as OrderProductAction.Send.Button.Tap:
                        
                        switch isSmsCode {
                        case true: sendVerifyRequest()
                        case false: sendLeadRequest()
                        }
                        
                        state = .loading
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            smsCode.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as OrderProductAction.Resend.Tap:

                        state = .normal
                        smsCode.isResend = false
                        
                        updateTimer()
                        sendLeadRequest()
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            smsCode.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                   
                    if text.count == 6 {
                        sendButton.style = .red
                    }
                    
                }.store(in: &bindings)
            
            $state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    switch state {
                    case .normal:
                        
                        sendButton.state = .button
                        sendButton.style = .gray
                        
                    case .loading:
                        sendButton.state = .spinner
                        
                    case .error:
                        
                        sendButton.state = .button
                        sendButton.style = .red
                    }
                    
                }.store(in: &bindings)

            isValidatePersonalData
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isValidate in
                    
                    switch isValidate {
                    case true: sendButton.style = .red
                    case false: sendButton.style = .gray
                    }
                    
                }.store(in: &bindings)
            
            isValidateSmsCode
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isValidate in

                    if isSmsCode == true {
                        
                        switch isValidate {
                        case true: sendButton.style = .red
                        case false: sendButton.style = .gray
                        }
                    }
                    
                }.store(in: &bindings)

            $isSmsCode
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isSmsCode in

                    if isSmsCode == true {
                        updateTimer()
                    }
                    
                    let isEnabled = isSmsCode == false
                    
                    nameTextField.isUserInteractionEnabled = isEnabled
                    phoneNumber.isUserInteractionEnabled = isEnabled

                }.store(in: &bindings)
            
            phoneNumber.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    guard let text = text else {
                        return
                    }
                    
                    isValidPhoneNumber = isValidPhone(text)
                    self.phoneNumber.isError = !isValidPhoneNumber
                    
                }.store(in: &bindings)
        }
        
        private func checkSessionActive() {

            if model.authIsSessionActive == false {
                model.action.send(ModelAction.Auth.Session.Start.Request())
            }
        }
        
        private func isValidPhone(_ text: String) -> Bool {
            phoneNumber.phoneNumberFormatter.isValid(text)
        }
        
        private func updateTimer() {
            
            smsCode.timer = .init(style: .order, delay: 55) { [weak self] in
                self?.smsCode.isResend = true
            }
        }
        
        private func openLinkURL() {
            
            let linkURL = "https://www.forabank.ru/polozhenie/Soglasie_na_obrabotku_personalnyh_dannyh.pdf"

            guard let url = URL(string: linkURL) else {
                return
            }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        private func makeAlert(_ message: String) {

            alert = .init(
                title: "Ошибка",
                message: message,
                primary: .init(type: .default, title: "Ok") { [weak self] in
                    self?.alert = nil
                })
        }
        
        private func sendLeadRequest() {
            
            if let phone = phoneNumber.text, model.authIsSessionActive == true {
                
                model.action.send(ModelAction.Auth.OrderLead.Request(
                    firstName: nameTextField.text,
                    phone: phone,
                    device: UIDevice.current.systemName,
                    os: UIDevice.current.systemVersion,
                    cardTarif: productTariff,
                    cardType: productType)
                )
            }
        }
        
        private func sendVerifyRequest() {
            
            if let leadID = leadID {
                
                model.action.send(ModelAction.Auth.VerifyPhone.Request(
                    leadID: "\(leadID)",
                    smsCode: smsCode.text)
                )
            }
        }
    }
}

extension OrderProductView.ViewModel {
    
    var isValidateNameAndPhone: AnyPublisher<Bool, Never> {
        
        let isValidate = Publishers.CombineLatest(
            nameTextField.$text,
            $isValidPhoneNumber
        )
            .map { $0.0.isEmpty == false && $0.1 == true }
            .eraseToAnyPublisher()
        
        return isValidate
    }
    
    var isValidatePersonalData: AnyPublisher<Bool, Never> {
        
        let isValidate = Publishers.CombineLatest(
            isValidateNameAndPhone,
            agreeData.$isChecked
        )
            .map { $0.0 == true && $0.1 == true }
            .eraseToAnyPublisher()
        
        return isValidate
    }
    
    var isValidateSmsCode: AnyPublisher<Bool, Never> {
        
        let isValidate = Publishers.CombineLatest(
            isValidatePersonalData,
            smsCode.$text
        )
            .map { $0.0 == true && $0.1.count > 3 }
            .eraseToAnyPublisher()
        
        return isValidate
    }
}

extension OrderProductView.ViewModel {
    
    class PhoneNumberViewModel: TextFieldPhoneNumberView.ViewModel {
        
        @Published var isUserInteractionEnabled: Bool = true
        @Published var isError: Bool = false
    }
    
    class SmsCodeViewModel: TextFieldView.ViewModel {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        private var bindings = Set<AnyCancellable>()
        
        lazy var onAction: () -> Void = { [weak self] in
            self?.action.send(OrderProductAction.Resend.Tap())
        }
        
        var width: CGFloat {
            
            switch isResend {
            case true: return 164
            case false: return 55
            }
        }
    }
    
    class AgreeDataViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        @Published var isChecked: Bool
        
        let iTitle = "Я"
        let agreeTitle = "соглашаюсь"
        let personalTitle = "на обработку моих"
        let processing = "персональных данных"
        
        let checkBox: CheckBoxView.ViewModel
        private var bindings = Set<AnyCancellable>()
        
        lazy var onAction: () -> Void = { [weak self] in
            self?.action.send(OrderProductAction.Agree.Tap())
        }
        
        init(checkBox: CheckBoxView.ViewModel, isChecked: Bool) {
            
            self.checkBox = checkBox
            self.isChecked = isChecked
        }
        
        convenience init() {
            
            self.init(
                checkBox: .init(true),
                isChecked: true
            )
            
            bind()
        }
        
        private func bind() {
            
            checkBox.$isChecked
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isChecked in
                    
                    self.isChecked = isChecked
                    
                }.store(in: &bindings)
        }
    }

    class SendButtonViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var style: Style
        @Published var state: State
        
        let title = "Отправить"
        let icon = Image("Logo Fora Bank")
        
        lazy var onAction: () -> Void = { [weak self] in
            self?.action.send(OrderProductAction.Send.Button.Tap())
        }
        
        var color: Color {
            style.color
        }
        
        var isDisabled: Bool {
            
            switch style {
            case .red: return false
            case .gray: return true
            }
        }
        
        init(style: Style, state: State) {
            
            self.style = style
            self.state = state
        }
        
        convenience init() {
            
            self.init(
                style: .gray,
                state: .button
            )
        }
        
        enum Style {
            
            case gray
            case red
            
            var color: Color {
                
                switch self {
                case .gray: return .mainColorsGrayMedium
                case .red: return .mainColorsRed
                }
            }
        }
        
        enum State {
            
            case spinner
            case button
        }
    }
    
    struct ResendViewModel {

        let title: String
        let action: () -> Void

        init(_ title: String, action: @escaping () -> Void) {

            self.title = title
            self.action = action
        }
        
        init(_ action: @escaping () -> Void) {
            self.init("Отправить повторно", action: action)
        }
    }
    
    struct NotifyViewModel {
        
        let title = "Спасибо"
        let description = "В ближайшее время Вам позвонит\nсотрудник банка для\nподтверждения данных"
    }
}

// MARK: - View

struct OrderProductView: View {
    
    @ObservedObject var viewModel: ViewModel
    @State var showOk: Bool = true
    
    var body: some View {
        
        if viewModel.isOrderCompletion == false {
            
            VStack(spacing: 0) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 64, height: 64)
                    
                    Image.ic24UserPlus
                }
                
                VStack(alignment: .center, spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textH3M18240())
                        .foregroundColor(.mainColorsBlack)
                    
                    Text(viewModel.detailTitle)
                        .font(.textBodyMR14180())
                        .foregroundColor(.mainColorsGray)
                        .multilineTextAlignment(.center)
                    
                }.padding(.vertical, 22)
                
                VStack(spacing: 16) {
                    
                    NameView(viewModel: viewModel.nameTextField)
                    PhoneNumberView(viewModel: viewModel.phoneNumber)
                    
                    if viewModel.isSmsCode == true {
                        SmsCodeView(viewModel: viewModel.smsCode)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom)
                
                AgreeDataView(viewModel: viewModel.agreeData)
                
                SendButtonView(viewModel: viewModel.sendButton)
                    .padding(.vertical, 26)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .alert(item: $viewModel.alert) {
                Alert(with: $0)
            }
        
        } else {
           
            if showOk {
                NotifyView(viewModel: viewModel.notify)
                    .frame(height: 247)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                            showOk = false
                        })
                    }
            }
        }
    }
}

extension OrderProductView {
    
    struct NameView: View {
        
        @ObservedObject var viewModel: TextFieldView.ViewModel
        
        var body: some View {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                HStack(spacing: 16) {
                    
                    Image.ic24User
                        .foregroundColor(.mainColorsGray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Spacer()
                        
                        if viewModel.isActive == true {
                            
                            Text(viewModel.placeholder)
                                .font(.textBodyMR14180())
                                .foregroundColor(.mainColorsGray)
                        }
                        
                        TextFieldView(viewModel: viewModel)
                        
                        Spacer()
                    }
                }
                .animation(nil, value: viewModel.isEditing == false)
                .padding(.horizontal)

            }
            .disabled(viewModel.isUserInteractionEnabled == false)
            .frame(height: 72)
        }
    }
    
    struct PhoneNumberView: View {
        
        @ObservedObject var viewModel: ViewModel.PhoneNumberViewModel
        
        var body: some View {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                HStack(spacing: 16) {
                    
                    Image.ic24Smartphone
                        .foregroundColor(.mainColorsGray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Spacer()
                        
                        if viewModel.isActive == true {
                            
                            Text(viewModel.placeHolder.title)
                                .font(.textBodyMR14180())
                                .foregroundColor(.mainColorsGray)
                        }
                        
                        TextFieldPhoneNumberView(viewModel: viewModel)
                        
                        Spacer()
                    }
                    
                    if viewModel.isError == true {
                        
                        Image.ic24AlertCircle
                            .foregroundColor(.mainColorsRed)
                    }
                }
                .animation(nil, value: viewModel.isActive == false)
                .padding(.horizontal)
                
            }
            .disabled(viewModel.isUserInteractionEnabled == false)
            .frame(height: 72)
        }
    }

    struct SmsCodeView: View {
        
        @ObservedObject var viewModel: ViewModel.SmsCodeViewModel
        
        var body: some View {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                HStack(alignment: .top, spacing: 16) {
                    
                    Image.ic24SmsCode
                        .foregroundColor(.mainColorsGray)
                        .padding(.top, 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Spacer()
                        
                        if viewModel.isActive == true {

                            Text(viewModel.placeholder)
                                .font(.textBodyMR14180())
                                .foregroundColor(.mainColorsGray)
                        }
                        
                        TextFieldView(viewModel: viewModel)
                            .frame(height: 28)
                        
                        if let timer = viewModel.timer {

                            ZStack(alignment: .center) {

                                RoundedRectangle(cornerRadius: 14)
                                    .foregroundColor(.mainColorsWhite)

                                TimerView(viewModel: timer)
                                
                                if viewModel.isResend == true {
                                    OrderProductView.ResendView(viewModel: .init(viewModel.onAction))
                                }
                            }
                            .animation(nil, value: timer.value)
                            .frame(width: viewModel.width, height: 28)
                            .padding(.vertical, 4)
                        }
                        
                        Spacer()
                    }
                    
                    if viewModel.isError == true {
                        
                        Image.ic24AlertCircle
                            .foregroundColor(.mainColorsRed)
                            .padding(.top, 32)
                    }
                    
                }.padding(.horizontal)
                
            }
            .animation(nil, value: viewModel.isEditing)
            .frame(height: 108)
        }
    }
    
    struct AgreeDataView: View {
        
        let viewModel: ViewModel.AgreeDataViewModel
        
        var body: some View {
            
            HStack(alignment: .top, spacing: 16) {
                
                CheckBoxView(viewModel: viewModel.checkBox)
                    .accessibilityIdentifier("CheckBox")
                
                VStack(alignment: .leading, spacing: 3) {
                    
                    HStack(alignment: .top, spacing: 4) {
                        
                        Text(viewModel.iTitle)
                            .font(.textBodyMR14200())
                            .foregroundColor(.mainColorsGray)
                        
                        Button(action: viewModel.onAction) {
                            
                            Text(viewModel.agreeTitle)
                                .underline()
                                .font(.textBodyMR14200())
                                .foregroundColor(.mainColorsBlack)
                        }
                        
                        Text(viewModel.personalTitle)
                            .font(.textBodyMR14200())
                            .foregroundColor(.mainColorsGray)
                    }
                    
                    Text(viewModel.processing)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsGray)
                }
                
                Spacer()
                
            }.frame(height: 54)
        }
    }
    
    struct SendButtonView: View {
        
        @ObservedObject var viewModel: ViewModel.SendButtonViewModel
        
        var body: some View {
            
            switch viewModel.state {
            case .button:
                
                Button(action: viewModel.onAction) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(viewModel.color)
                        
                        Text(viewModel.title)
                            .font(.textH3SB18240())
                            .foregroundColor(.mainColorsWhite)
                    }
                }
                .disabled(viewModel.isDisabled)
                .frame(height: 56)
                
            case .spinner:
                
                SpinnerRefreshView(icon: viewModel.icon)
            }
        }
    }
    
    struct ResendView: View {

        let viewModel: ViewModel.ResendViewModel

        var body: some View {

            Button(action: viewModel.action) {

                ZStack {
                    
                    RoundedRectangle(cornerRadius: 14)
                        .foregroundColor(.mainColorsWhite)
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.mainColorsRed)
                    
                }.frame(width: 159, height: 28)
            }
        }
    }
    
    struct NotifyView: View {
        
        let viewModel: ViewModel.NotifyViewModel
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                ZStack(alignment: .center) {
                    
                    Circle()
                        .foregroundColor(.systemColorActive)
                        .frame(width: 64, height: 64)
                    
                    Image.ic24UserCheck
                        .resizable()
                        .foregroundColor(.mainColorsWhite)
                        .frame(width: 32, height: 32)
                
                }
                .padding(.vertical, 8)

                Text(viewModel.title)
                    .font(.textH3M18240())
                    .foregroundColor(.mainColorsBlack)
                    .padding(.top, 6)

                Text(viewModel.description)
                    .font(.textBodyMR14180())
                    .foregroundColor(.mainColorsGray)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
        }
    }
}

// MARK: - Action

enum OrderProductAction {

    enum Send {
        
        enum Button {
            
            struct Tap: Action {}
        }
    }
    
    enum Timer {

        struct Completion: Action {}
    }
    
    enum Resend {
        
        struct Tap: Action {}
    }
    
    enum Agree {
    
        struct Tap: Action {}
    }
}

// MARK: - Preview

struct OrderProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OrderProductView(viewModel: .init(.emptyMock,
                                          productData: .init(name: "",
                                                             description: [],
                                                             imageEndpoint: "",
                                                             infoURL: URL(string: "http://google.com")!,
                                                             orderURL: URL(string: "http://google.com")!,
                                                             tariff: 3,
                                                             productType: 6)))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
