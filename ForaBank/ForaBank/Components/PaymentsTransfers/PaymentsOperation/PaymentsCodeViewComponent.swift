//
//  PaymentsCodeViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.11.2022.
//

import SwiftUI
import Combine

extension PaymentsCodeView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let icon: Image
        let description: String
        let textField: TextFieldRegularView.ViewModel
        @Published var title: String?
        @Published var editingState: EditingState
        @Published var resendState: ResendState?

        var parameterCode: Payments.ParameterCode? { source as? Payments.ParameterCode }
        override var isValid: Bool { parameterCode?.validator.isValid(value: textField.text ?? "") ?? false }

        init(icon: Image, description: String, title: String?, textField: TextFieldRegularView.ViewModel, editingState: EditingState, resendState: PaymentsCodeView.ViewModel.ResendState?, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            self.icon = icon
            self.description = description
            self.title = title
            self.editingState = editingState
            self.resendState = resendState
            self.textField = textField
            super.init(source: source)
        }
        
        init(with parameterCode: Payments.ParameterCode) {
            
            self.icon = parameterCode.icon.image ?? Image.ic24SmsCode
            self.description = parameterCode.title
            self.textField = .init(text: parameterCode.parameter.value ?? "", placeholder: parameterCode.title, style: .number, limit: parameterCode.limit, needCloseButton: true)
            self.editingState = .idle
            self.resendState = nil
            
            super.init(source: parameterCode)
            
            self.resendState = .timer(.init(delay: parameterCode.timerDelay, completeAction: { [weak self] in
                
                self?.action.send(PaymentsParameterViewModelAction.Code.ResendDelayIsOver())
            }))
            
            bind()
        }
        
        private func bind() {
            
            typealias CodeAction = PaymentsParameterViewModelAction.Code
            
            action
                .compactMap { $0 as? CodeAction.ResendDelayIsOver }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    withAnimation {
                        
                        resendState = .button(.init(
                            action: { [weak self] in
                                
                                self?.action.send(PaymentsParameterViewModelAction.Code.ResendButtonDidTapped())
                            }
                        ))
                    }
                }
                .store(in: &bindings)
            
            action
                .compactMap { $0 as? CodeAction.ResendButtonDidTapped }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    guard let parameterInput = parameterCode else {
                        return
                    }
                    
                    withAnimation {
                        
                        resendState = .timer(.init(
                            delay: parameterInput.timerDelay,
                            completeAction: { [weak self] in
                                
                                self?.action.send(PaymentsParameterViewModelAction.Code.ResendDelayIsOver())
                            }
                        ))
                    }
                }
                .store(in: &bindings)

            action
                .compactMap { $0 as? CodeAction.IncorrectCodeEntered }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    guard let parameterInput = parameterCode else {
                        return
                    }
                    
                    withAnimation {
                        
                        editingState = .error(parameterInput.errorMessage)
                    }
                }
                .store(in: &bindings)

            action
                .compactMap { $0 as? CodeAction.ResendCodeDisabled }
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    withAnimation {
                        
                        resendState = nil
                    }
                }
                .store(in: &bindings)

            textField.$text
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    update(value: text)
                    
                }.store(in: &bindings)
            
            textField.isEditing
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEditing in
                    
                    if isEditing || textField.hasValue {
                        
                        withAnimation {

                            title = description
                        }
                        
                    } else {
                        
                        withAnimation {

                            title = nil
                        }
                    }
                    
                }.store(in: &bindings)
        }
        
        override func updateValidationWarnings() {
            
            //TODO: implement validation warning
        }
    }
}

//MARK: - Types

extension PaymentsCodeView.ViewModel {
    
    enum EditingState: Equatable {
        
        case idle
        case editing
        case error(String)
    }
    
    enum ResendState {
        
        case timer(TimerViewModel)
        case button(RepeatButtonViewModel)
    }
    
    struct RepeatButtonViewModel {
        
        let title = "Отправить повторно"
        let action: () -> Void
        
        init(action: @escaping () -> Void = {}) {
            
            self.action = action
        }
    }
    
    class TimerViewModel: ObservableObject {
        
        let delay: TimeInterval
        @Published var value: String
        let completeAction: () -> Void
        
        private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        private let startTime = Date().timeIntervalSinceReferenceDate
        private var formatter: DateComponentsFormatter
        
        private var bindings = Set<AnyCancellable>()
        
        init(delay: TimeInterval, formatter: DateComponentsFormatter = .formatTime, completeAction: @escaping () -> Void) {
            
            self.formatter = formatter
            self.delay = delay
            self.value = formatter.string(from: delay) ?? "0 :\(delay)"
            self.completeAction = completeAction
            
            bind()
        }
        
        func bind() {
            
            timer
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] time in
                    
                    let delta = time.timeIntervalSinceReferenceDate - startTime
                    let remain = delay - delta
                    
                    if remain <= 1 { completeAction() }
                    
                    value = formatter.string(from: remain) ?? "0 :\(remain)"
                    
                }.store(in: &bindings)
        }
    }
}


//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum Code {
    
        struct ResendDelayIsOver: Action {}
        struct ResendButtonDidTapped: Action {}
        struct ResendCodeDisabled: Action {}
        struct IncorrectCodeEntered: Action {}
    }
}

//MARK: - View

struct PaymentsCodeView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        hStack
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
    }
    
    var hStack: some View {
        
        HStack(alignment: .top, spacing: 16) {
            
            icon
                .frame(width: 24, height: 24)
                .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                
                VStack(alignment: .leading, spacing: 4) {
                    title
                    
                    textField
                        .frame(maxWidth: .infinity)
                        .overlay(resendStateView)
                }
                .frame(minHeight: 44)
                
                errorLabel
            }
        }
    }
    
    private var icon: some View {
        
        viewModel.icon
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.mainColorsGray)
    }
    
    @ViewBuilder
    private var title: some View {
        
        if let title = viewModel.title {
            
            Text(title)
                .font(.textBodyMR14180())
                .foregroundColor(Color.textPlaceholder)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .opacity
                    )
                )
        }
    }
    
    private var textField: some View {
        
        TextFieldRegularView(viewModel: viewModel.textField, font: .textH4M16240())
            .onTapGesture {
                viewModel.editingState = .idle
            }
            .foregroundColor(.textSecondary)
            .textFieldStyle(DefaultTextFieldStyle())
            .frame(height: 24)
            .keyboardType(.numberPad)
    }
    
    @ViewBuilder
    private var resendStateView: some View {
        
        if let resendState = viewModel.resendState {
            
            Group {
                switch resendState {
                case let .button(button):
                    Button(action: button.action) {
                        
                        Text(button.title)
                            .foregroundColor(Color.textSecondary)
                            .font(.textBodyMR14180())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white)
                            .cornerRadius(90)
                            .frame(height: 24)
                    }
                    
                case let .timer(timerViewModel):
                    PaymentsCodeView.TimerView(viewModel: timerViewModel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    @ViewBuilder
    private var errorLabel: some View {
        
        if case let .error(errorMessage) = viewModel.editingState {
            
            Text(errorMessage)
                .foregroundColor(.systemColorError)
                .font(.textBodySR12160())
        }
    }
}

extension PaymentsCodeView {
    
    struct TimerView: View {
        
        @ObservedObject var viewModel: PaymentsCodeView.ViewModel.TimerViewModel
        
        var body: some View {
            
            Text(viewModel.value)
                .foregroundColor(Color.textRed)
                .font(.textBodySR12160())
        }
    }
}

struct PaymentCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            previewGroup()
            
            VStack(content: previewGroup)
                .previewDisplayName("Xcode 14")
        }
        .previewLayout(.sizeThatFits)
    }
    
    private static func previewGroup() -> some View {
        
        Group {
            
            Group {
                
                PaymentsCodeView(viewModel: .sample)
                PaymentsCodeView(viewModel: .sampleCorrect)
                PaymentsCodeView(viewModel: .sampleError)
                PaymentsCodeView(viewModel: .sampleButton)
            }
            .background(Color.mainColorsGrayLightest)
            .frame(width: 375)
            .border(.pink)
            
            paymentsGroupView(item: .sample,        height: 120)
            paymentsGroupView(item: .sampleCorrect, height: 140)
            paymentsGroupView(item: .sampleError,   height: 180)
            paymentsGroupView(item: .sampleButton,  height: 140)
        }
    }

    private static func paymentsGroupView(
        item: PaymentsCodeView.ViewModel,
        height: CGFloat
    ) -> some View {
        
        PaymentsGroupView(viewModel: .init(items: [item]))
            .previewLayout(.fixed(width: 375, height: height))
    }
}

//MARK: - Preview Content

extension PaymentsCodeView.ViewModel {
    
    static let sample = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: nil, textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .idle, resendState: .timer(.init(delay: 5, completeAction: {})))
    
    static let sampleCorrect = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: "Введите код из смс", textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .editing, resendState: .timer(.init(delay: 60, completeAction: {})))
    
    static let sampleError = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: "Введите код из смс", textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .error("Код введен неправильно"), resendState: .timer(.init(delay: 60, completeAction: {})))
    
    static let sampleButton = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: "Введите код из смс", textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .idle, resendState: .button(.init()))
}
