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
            self.textField = .init(text: parameterCode.parameter.value ?? "", placeholder: parameterCode.title, style: .number, limit: parameterCode.limit)
            self.editingState = .idle
            self.resendState = nil
            
            super.init(source: parameterCode)
            
            self.resendState = .timer(.init(delay: parameterCode.timerDelay, completeAction: { [weak self] in
                
                self?.action.send(PaymentsParameterViewModelAction.Code.ResendDelayIsOver())
            }))
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] action in
                    
                    switch action {
                    case _ as PaymentsParameterViewModelAction.Code.ResendDelayIsOver:
                        withAnimation {
                            
                            resendState = .button(.init(action: { [weak self] in
                                
                                self?.action.send(PaymentsParameterViewModelAction.Code.ResendButtonDidTapped())
                            }))
                        }
                        
                    case _ as PaymentsParameterViewModelAction.Code.ResendButtonDidTapped:
                        guard let parameterInput = parameterCode else {
                            return
                        }

                        withAnimation {
                            
                            resendState = .timer(.init(delay: parameterInput.timerDelay, completeAction: { [weak self] in
                                
                                self?.action.send(PaymentsParameterViewModelAction.Code.ResendDelayIsOver())
                            }))
                        }
                        
                    case _ as PaymentsParameterViewModelAction.Code.EnterredCodeIncorrect:
                        guard let parameterInput = parameterCode else {
                            return
                        }
                        
                        withAnimation {
                            
                            editingState = .error(parameterInput.errorMessage)
                        }
                        
                    case _ as PaymentsParameterViewModelAction.Code.ResendCodeDisabled:
                        withAnimation {
                            
                            resendState = nil
                        }
                        

                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            textField.$text
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    value = value.updated(with: text)
                    
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
    
    enum EditingState {
        
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
        struct EnterredCodeIncorrect: Action {}
    }
}

//MARK: - View

struct PaymentsCodeView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var titleColor: Color {
        
        switch viewModel.editingState {
        case .editing, .error: return .textRed
        default: return .textPlaceholder
        }
    }

    var dividerColor: Color {
        
        switch viewModel.editingState {
        case .idle: return .bordersDivider
        case .editing: return .mainColorsBlack
        case .error: return .textRed
        }
    }
    
    var dividerOpacity: CGFloat {
        
        switch viewModel.editingState {
        case .idle: return 0.2
        case .editing, .error: return 1.0
        }
    }
    
    var errorLabel: String? {
        
        guard case .error(let errorMessage) = viewModel.editingState else {
            return nil
        }
        
        return errorMessage
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(alignment: .top, spacing: 20) {
                
                viewModel.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 24, height: 24)
                    .padding(.top, 12)
                
                VStack(spacing: 0) {
                    
                    if let title = viewModel.title {
                        
                        Text(title)
                            .font(.textBodyMR14180())
                            .foregroundColor(Color.textPlaceholder)
                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                            .frame(maxWidth: .infinity, alignment: .leading)

                    }
                    
                    VStack(spacing: 0) {
                        
                        TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 14))
                            .onTapGesture {
                                viewModel.editingState = .idle
                            }
                    }
                    
                    if let resendState = viewModel.resendState {
                        
                        switch resendState {
                        case .button(let button):
                            Button(action: button.action) {
                                
                                Text(button.title)
                                    .font(.buttonExtraSmallR12140())
                                    .foregroundColor(Color.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.top, 3)
                                    .background(Color.white)
                                    .cornerRadius(90)
                                    .frame(height: 24)
                                    .cornerRadius(90)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                        case .timer(let timerViewModel):
                            PaymentsCodeView.TimerView(viewModel: timerViewModel)
                        }
                    }
                    
                    if let errorLabel = errorLabel {
                        
                        Text(errorLabel)
                            .font(.textBodySR12160())
                            .foregroundColor(Color.textPlaceholder)
                    }
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
        }
    }
}

extension PaymentsCodeView {
    
    struct TimerView: View {
        
        @ObservedObject var viewModel: PaymentsCodeView.ViewModel.TimerViewModel
        
        var body: some View {
            
            Text(viewModel.value)
                .font(.buttonExtraSmallR12140())
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.white)
                .cornerRadius(90)
                .foregroundColor(Color.textRed)
                .frame(maxWidth: .infinity, alignment: .leading)

        }
    }
}

struct PaymentCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsGroupView(viewModel: .init(items: [PaymentsCodeView.ViewModel.sample]))
            .previewLayout(.fixed(width: 375, height: 120))
        
        PaymentsGroupView(viewModel: .init(items: [PaymentsCodeView.ViewModel.sampleCorrect]))
            .previewLayout(.fixed(width: 375, height: 140))
        
        PaymentsGroupView(viewModel: .init(items: [PaymentsCodeView.ViewModel.sampleError]))
            .previewLayout(.fixed(width: 375, height: 180))
        
        PaymentsGroupView(viewModel: .init(items: [PaymentsCodeView.ViewModel.sampleButton]))
            .previewLayout(.fixed(width: 375, height: 140))
    }
}

//MARK: - Preview Content

extension PaymentsCodeView.ViewModel {
    
    static let sample = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: nil, textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .idle, resendState: .timer(.init(delay: 5, completeAction: {})))
    
    static let sampleCorrect = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: "Введите код из смс", textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .editing, resendState: .timer(.init(delay: 60, completeAction: {})))
    
    static let sampleError = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: "Введите код из смс", textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .error("Код введен неправильно"), resendState: .timer(.init(delay: 60, completeAction: {})))
    
    static let sampleButton = PaymentsCodeView.ViewModel(icon: .ic24SmsCode, description: "Введите код из смс", title: "Введите код из смс", textField: .init(text: nil, placeholder: "Введите код из смс", style: .number, limit: 6), editingState: .idle, resendState: .button(.init()))
}
