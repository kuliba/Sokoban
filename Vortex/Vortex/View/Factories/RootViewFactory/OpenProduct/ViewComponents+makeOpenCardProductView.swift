//
//  ViewComponents+makeOpenCardProductView.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.02.2025.
//

// TODO: extract to separate file
import UIPrimitives

extension ViewComponents {
    
    @inlinable
    func makeGeneralIconView(
        md5Hash: String
    ) -> UIPrimitives.AsyncImage {
        
        return makeGeneralIconView(.md5Hash(.init(md5Hash)))
    }
}

import OrderCard
import OTPInputComponent
import PaymentComponents
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
            
            VStack {
                
                OrderCard.OrderCardView(
                    state: state,
                    event: event,
                    config: .iVortex,
                    factory: .init(
                        makeIconView: makeIconView,
                        makeBannerImageView: makeGeneralIconView
                    )
                ) { confirmation in
                    
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
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                continueButton(isLoading: state.loadableForm.isLoading) {
                    
                    event(.continue)
                }
                .disabled(!state.isValid)
            }
            .disabled(state.loadableForm.isLoading)
        }
    }
    
    private func continueButton(
        isLoading: Bool,
        action: @escaping () -> Void
    ) -> some View {
        
        PaymentComponents.ButtonView.goToMain(
            title: "Продолжить",
            goToMain: action
        )
        .loader(isLoading: isLoading, color: .clear)
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

// MARK: - Helpers

private extension OpenCardDomain.State {
    
    var consent: Bool { loadableForm.state?.consent ?? false }
}

// MARK: - Adapters

extension OpenCardDomain.LoadFailure: Identifiable {
    
    public var id: String { message + String(describing: message) }
    
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
