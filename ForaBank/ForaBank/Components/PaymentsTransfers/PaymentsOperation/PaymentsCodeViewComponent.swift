//
//  PaymentsCodeViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.11.2022.
//

import SwiftUI
import Combine

extension PaymentCodeView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let description: String
        @Published var content: String
        @Published var title: String?
        @Published var timerState: TimerState
        @Published var errorLabel: String?
        let icon: Image
        let timerDelay: TimeInterval
        
        private var bindings = Set<AnyCancellable>()
        
        enum TimerState {
            
            case timer(TimerViewModel)
            case button(RepeatButtonViewModel)
        }
        
        internal init(description: String, content: String, title: String, icon: Image, timerState: PaymentCodeView.ViewModel.TimerState, errorLabel: String? = nil, bindings: Set<AnyCancellable> = Set<AnyCancellable>(), timerDelay: TimeInterval, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            self.description = description
            self.content = content
            self.title = title
            self.icon = icon
            self.timerState = timerState
            self.errorLabel = errorLabel
            self.timerDelay = timerDelay
            self.bindings = bindings
            super.init(source: source)
        }
        
        init(with parameterInput: Payments.ParameterCode) {
            
            self.icon = Image.ic24MessageSquare
            self.content = parameterInput.parameter.value ?? ""
            self.description = parameterInput.title
            self.timerState = .timer(.init(delay: parameterInput.timerDelay, completeAction: {}))
            self.timerDelay = parameterInput.timerDelay
            self.errorLabel = nil
            
            super.init(source: parameterInput)
            
            self.timerState = .timer(.init(delay: parameterInput.timerDelay, completeAction: { [weak self] in
                
                self?.timerState = .button(.init(action: { [weak self] in
                    
                    self?.action.send(PaymentsParameterViewModelAction.ResendButton.DidTapped())
                }))
            }))
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] action in
                    
                    switch action {
                        
                    case _ as PaymentsParameterViewModelAction.ResendButton.DidTapped:
                        
                        self.timerState = .timer(.init(delay: self.timerDelay, completeAction: { [weak self] in
                            
                            self?.timerState = .button(.init(action: { [weak self] in
                                
                                self?.action.send(PaymentsParameterViewModelAction.ResendButton.DidTapped())
                            }))
                        }))
                        
                    default: break
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
            private let startTime = Date.timeIntervalSinceReferenceDate
            private var formatter: DateComponentsFormatter
            
            private var bindings = Set<AnyCancellable>()
            
            init(delay: TimeInterval, formatter: DateComponentsFormatter = .formatTime, completeAction: @escaping () -> Void) {
                
                self.formatter = formatter
                self.delay = delay
                self.value = ""
                self.completeAction = completeAction
                
                bind()
                value = formatter.string(from: delay) ?? "0 :\(delay)"
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
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum ResendButton {
        
        struct DidTapped: Action {}
    }
}

struct PaymentCodeView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 20) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24, alignment: .center)
                
                VStack {
                    
                    HStack {
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)
                                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                            
                            Spacer()
                        }
                        
                        switch viewModel.timerState {
                        case .button(let button):
                            Button(action: button.action){
                                
                                Text(button.title)
                                    .font(.buttonExtraSmallR12140())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2)
                                    .foregroundColor(Color.textSecondary)
                                    .background(Color.secondary)
                                    .cornerRadius(90)
                            }
                            
                        case .timer(let timer):
                            Text(timer.value)
                                .foregroundColor(Color.textRed)
                        }
                    }
                    
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
        .padding(.horizontal, 20)
    }
}

struct PaymentCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentCodeView(viewModel: .init(description: "Введите код из смс", content: "", title: "Введите код из смс", icon: Image.ic24MessageSquare, timerState: .timer(.init(delay: 60, completeAction: {})), errorLabel: "Код введен неправильно", timerDelay: 60))
    }
}
