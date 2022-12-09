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
        @Published var content: String
        @Published var title: String?
        @Published var editingState: EditingState
        @Published var resendState: ResendState?

        var parameterInput: Payments.ParameterCode? { source as? Payments.ParameterCode }
        override var isValid: Bool { return parameterInput?.validator.isValid(value: content) ?? false }

        init(icon: Image, description: String, content: String, title: String?, editingState: EditingState, resendState: PaymentsCodeView.ViewModel.ResendState?, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            self.icon = icon
            self.description = description
            self.content = content
            self.title = title
            self.editingState = editingState
            self.resendState = resendState
            super.init(source: source)
        }
        
        init(with parameterInput: Payments.ParameterCode) {
            
            self.icon = Image.ic24MessageSquare
            self.content = parameterInput.parameter.value ?? ""
            self.description = parameterInput.title
            self.editingState = .idle
            self.resendState = nil
            
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
                        
                    case _ as PaymentsParameterViewModelAction.Code.EnterredCodeIncorrect:
                        guard let parameterInput = parameterInput else {
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
            
            $content
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] content in
                    
                    value = value.updated(with: content)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        title = content.count > 0 ? description : nil
                    }
                    
                    switch editingState {
                    case .idle, .error:
                        
                        withAnimation {
                            
                            editingState = .editing
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
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
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                
                if let title = viewModel.title {
                    
                    Text(title)
                        .font(.textBodySR12160())
                        .foregroundColor(titleColor)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                }
                
                Spacer()
                
                if let resendState = viewModel.resendState {
                    
                    switch resendState {
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
            }
            .frame(height: 24)
            .padding(.leading, 48)
            
            HStack(spacing: 20) {
                
                viewModel.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 24, height: 24)
                    .padding(.leading, 4)
                
                VStack(spacing: 0) {
                    
                    TextField(viewModel.description, text: $viewModel.content) { _ in } onCommit: {
                        
                        withAnimation {
                            viewModel.editingState = .idle
                        }
                    }
                    .foregroundColor(.textSecondary)
                    .font(.textBodyMM14200())
                    .textFieldStyle(DefaultTextFieldStyle())
                    .keyboardType(.numberPad)
                }
            }
            
            Divider()
                .frame(height: 1)
                .background(dividerColor)
                .opacity(dividerOpacity)
                .padding(.top, 12)
                .padding(.leading, 48)
            
            if let errorLabel = errorLabel {
                
                Text(errorLabel)
                    .font(.textBodySR12160())
                    .foregroundColor(Color.textRed)
                    .padding(.top, 8)
                    .padding(.leading, 48)
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
    
    static let sample = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "", title: nil, editingState: .idle, resendState: .timer(.init(delay: 5, completeAction: {})))
    
    static let sampleCorrect = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "12345", title: "Введите код из смс", editingState: .editing, resendState: .timer(.init(delay: 60, completeAction: {})))
    
    static let sampleError = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "12345", title: "Введите код из смс", editingState: .error("Код введен неправильно"), resendState: .timer(.init(delay: 60, completeAction: {})))
    
    static let sampleButton = PaymentsCodeView.ViewModel(icon: .ic24MessageSquare, description: "Введите код из смс", content: "12345", title: "Введите код из смс", editingState: .idle, resendState: .button(.init()))
}
