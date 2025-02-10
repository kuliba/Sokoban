//
//  ViewComponents+makeOpenCardProductView.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.02.2025.
//

import OTPInputComponent
import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeOpenCardProductView(
        _ binder: OpenCardDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            ZStack(alignment: .top) {
                
                state.informer.map(InformerInternalView.init)
                    .padding(.top, 16	)
                    .zIndex(1)
                
                makeOpenCardProductContentView(binder.content)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal)
                    .alert(
                        item: state.stringAlert,
                        content: { $0.error(dismiss: dismiss) }
                    )
            }
        }
    }
    
    @inlinable
    func makeOpenCardProductContentView(
        _ content: OpenCardDomain.Content
    ) -> some View {
        
        RxWrapperView(model: content) { state, event in
            
            switch state.formResult {
            case .none, .failure:
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.tertiary)
                    ._shimmering(isActive: state.formResult == nil)
                
            case let .success(form):
                switch form.confirmation {
                case .none:
                    VStack {
                        
                        Text("TBD: openCard Form without confirmation")
                        
                        Toggle(
                            "SMS/Push Expanded",
                            isOn: .init(
                                get: { state.form?.messages.isOn ?? false },
                                set: { event(.setMessages($0)) }
                            )
                        )
                        
                        Spacer()
                        
                        continueButton(isLoading: state.isLoading) {
                            
                            event(.continue)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .disabled(state.isLoading)
                    
                case .failure:
                    Text("TBD: openCard Form with confirmation failure")
                        .foregroundStyle(.red)
                    
                case let .success(confirmation):
                    VStack {
                        
                        Text("TBD: openCard Form with confirmation")
                        
                        Toggle(
                            "SMS/Push Expanded",
                            isOn: .init(
                                get: { state.form?.messages.isOn ?? false },
                                set: { event(.setMessages($0)) }
                            )
                        )
                        
                        makeOTPView(viewModel: confirmation.otp)
                        
                        HStack {
                            
                            PaymentsCheckView.CheckBoxView(
                                isChecked: state.consent,
                                activeColor: .systemColorActive
                            )
                            
                            Text("Consent")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.textBodyMR14200())
                                .foregroundColor(.textPlaceholder)
                        }
                        .onTapGesture { event(.setConsent(!state.consent)) }
                        .animation(.easeInOut, value: state.consent)
                        
                        Spacer()
                        
                        Text(String(describing: state.payload))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        continueButton(isLoading: state.isLoading) {
                            
                            event(.continue)
                        }
                        .disabled(!state.isValid)
                    }
                    .disabled(state.isLoading)
                }
            }
        }
    }
    
    private func continueButton(
        isLoading: Bool,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            if isLoading {
                ProgressView()
            } else {
                Text("Continue")
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
    @inlinable
    func makeOTPView(
        viewModel: TimedOTPInputViewModel
    ) -> some View {
        
        TimedOTPInputWrapperView(
            viewModel: viewModel,
            config: .iVortex,
            iconView: { makeIconView(.md5Hash("sms")) },
            warningView: {
                
                OTPWarningView(text: viewModel.state.warning, config: .iVortex)
            }
        )
        .paddedRoundedBackground()
        .keyboardType(.numberPad)
    }
}

// MARK: - Adapters

extension OpenCardDomain.LoadFailure: Identifiable {
    
    var id: String { message + String(describing: message) }
    
    func alert(
        title: String = "Ошибка",
        dismiss: @escaping () -> Void
    ) -> SwiftUI.Alert {
        
        return .init(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("OK"), action: dismiss)
        )
    }
}

private extension OpenCardDomain.FlowDomain.State {
    
    var informer: Informer? {
        
        guard case let .failure(failure) = navigation,
              case .informer = failure.type
        else { return nil }
        
        return .failure(message: failure.message)
    }
    
    var stringAlert: StringAlert? {
        
        guard case let .failure(failure) = navigation,
              case .alert = failure.type
        else { return nil }
        
        return .init(message: failure.message)
    }
}

private extension OTPInputState {
    
    var warning: String? {
        
        guard case let .input(input) = status,
              case let .failure(.serverError(warning)) = input.otpField.status
        else { return nil }
        
        return warning
    }
}

private struct Informer {
    
    let message: String
    let icon: Image
    let color: Color
    
    static func failure(
        message: String
    ) -> Self {
        
        return .init(message: message, icon: .ic24Close, color: .mainColorsBlackMedium)
    }
}

private extension InformerInternalView {
    
    init(_ informer: Informer) {
        
        self.init(
            message: informer.message,
            icon: informer.icon,
            color: informer.color
        )
    }
}
