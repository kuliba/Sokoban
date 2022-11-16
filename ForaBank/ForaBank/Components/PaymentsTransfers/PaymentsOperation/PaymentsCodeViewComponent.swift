//
//  PaymentsCodeViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.11.2022.
//

import SwiftUI
import Combine

extension PaymentsCodeView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let icon: Image
        let description: String
        @Published var content: String
        @Published var title: String?
        @Published var resendState: ResendState
        @Published var errorLabel: String?

        var parameterInput: Payments.ParameterCode? { source as? Payments.ParameterCode }
        override var isValid: Bool { return parameterInput?.validator.isValid(value: content) ?? false }

        init(icon: Image, description: String, content: String, title: String?, resendState: PaymentsCodeView.ViewModel.ResendState, errorLabel: String? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            self.icon = icon
            self.description = description
            self.content = content
            self.title = title
            self.resendState = resendState
            self.errorLabel = errorLabel
            super.init(source: source)
        }
        
        init(with parameterInput: Payments.ParameterCode) {
            
            self.icon = Image.ic24MessageSquare
            self.content = parameterInput.parameter.value ?? ""
            self.description = parameterInput.title
            self.resendState = .timer(.init(delay: parameterInput.timerDelay, completeAction: {}))
            self.errorLabel = nil
            
            super.init(source: parameterInput)
            
            self.resendState = .timer(.init(delay: parameterInput.timerDelay, completeAction: { [weak self] in
                
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
                        guard let parameterInput = parameterInput else {
                            return
                        }

                        withAnimation {
                            
                            resendState = .timer(.init(delay: parameterInput.timerDelay, completeAction: { [weak self] in
                                
                                self?.action.send(PaymentsParameterViewModelAction.Code.ResendDelayIsOver())
                            }))
                        }

                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $content
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] content in
                    
                    value = value.updated(with: content)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        title = content.count > 0 ? description : nil
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Types

extension PaymentsCodeView.ViewModel {
    
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
    }
}

//MARK: - View

struct PaymentsCodeView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 20) {
                
                viewModel.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 24, height: 24, alignment: .center)
                
                VStack {
                    
                    HStack {
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)
                                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                        }
                        
                        Spacer()
                        
                        switch viewModel.resendState {
                        case .button(let button):
                            Button(action: button.action) {
                                
                                Text(button.title)
                                    .font(.buttonExtraSmallR12140())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2)
                                    .foregroundColor(Color.textSecondary)
                                    .frame(height: 24)
                                    .background(Color.buttonSecondary)
                                    .cornerRadius(90)
                            }
                            
                        case .timer(let timerViewModel):
                            PaymentsCodeView.TimerView(viewModel: timerViewModel)
                        }
                    }
                    .frame(height: 24)
                    
                    HStack(spacing: 20) {
                        
                        VStack {
                            
                            TextField(viewModel.description, text: $viewModel.content)
                                .foregroundColor(.textSecondary)
                                .font(.textBodyMM14200())
                                .textFieldStyle(DefaultTextFieldStyle())
                            
                            Divider()
                                .frame(height: 1)
                                .background(Color.bordersDivider)
                                .opacity(viewModel.isEditable ? 1.0 : 0.2)
                                .padding(.top, 12)
                                .padding(.leading, 48)
                            
                            HStack {
                                
                                if let errorLabel = viewModel.errorLabel {
                                    
                                    Text(errorLabel)
                                        .font(.textBodySR12160())
                                        .foregroundColor(Color.textRed)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension PaymentsCodeView {
    
    struct TimerView: View {
        
        @ObservedObject var viewModel: PaymentsCodeView.ViewModel.TimerViewModel
        
        var body: some View {
            
            Text(viewModel.value)
                .font(.buttonExtraSmallR12140())
                .foregroundColor(Color.textRed)
        }
    }
}

struct PaymentCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsCodeView(viewModel: .sample)
            .padding(.horizontal, 20)
            .previewLayout(.fixed(width: 375, height: 120))
        
        PaymentsCodeView(viewModel: .sampleCorrect)
            .padding(.horizontal, 20)
            .previewLayout(.fixed(width: 375, height: 120))
        
        PaymentsCodeView(viewModel: .sampleError)
            .padding(.horizontal, 20)
            .previewLayout(.fixed(width: 375, height: 120))
        
        PaymentsCodeView(viewModel: .sampleButton)
            .padding(.horizontal, 20)
            .previewLayout(.fixed(width: 375, height: 120))
    }
}

//MARK: - Preview Content

extension PaymentsCodeView.ViewModel {
    
    static let sample = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "", title: nil, resendState: .timer(.init(delay: 5, completeAction: {})), errorLabel: nil)
    
    static let sampleCorrect = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "12345", title: "Введите код из смс", resendState: .timer(.init(delay: 60, completeAction: {})), errorLabel: nil)
    
    static let sampleError = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "12345", title: "Введите код из смс", resendState: .timer(.init(delay: 60, completeAction: {})), errorLabel: "Код введен неправильно")
    
    static let sampleButton = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "12345", title: "Введите код из смс", resendState: .button(.init()), errorLabel: nil)
}
