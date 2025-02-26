//
//  ViewComponents+makeOpenSavingsAccountView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import OTPInputComponent
import PaymentComponents
import RxViewModel
import SavingsAccount
import SwiftUI
import UIPrimitives
import PaymentCompletionUI
import TextFieldComponent

extension ViewComponents {
    
    @inlinable
    func makeOpenSavingsAccountView(
        _ binder: OpenSavingsAccountDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            ZStack(alignment: .top) {
                
                state.informer.map(InformerInternalView.init)
                    .padding(.top, 16)
                    .zIndex(1)
                
                makeOpenSavingsAccountContentView(binder.content, .prod, dismiss)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .alert(
                        item: state.stringAlert,
                        content: { $0.error(dismiss: dismiss) }
                    )
            }
            .onDisappear { binder.flow.event(.dismiss)}
        }
    }
    
    @inlinable
    func makeOpenSavingsAccountContentView(
        _ content: OpenSavingsAccountDomain.Content,
        _ config: OrderSavingsAccountConfig,
        _ dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: content) { state, event in
            
            RefreshableScrollView(
                action: { event(.load) },
                showsIndicators: false,
                coordinateSpaceName: "openSavingsAccountScroll"
            ) {
                
                SavingsAccount.OrderAccountView(
                    state: state,
                    event: event,
                    config: config,
                    factory: .init(
                        makeIconView: makeIconView,
                        makeBannerImageView: makeGeneralIconView
                    ),
                    confirmationView: {
                        
                        confirmationView($0, state, event)
                    }, 
                    productSelectView: {
                        
                        makeProductSelectView(
                            state: state.productSelect,
                            event: { event(.productSelect($0)) })
                    }
                )
                .onFirstAppear { content.event(.load) }
                .padding(.horizontal)
            }
            .navigationBarWithBack(
                title: .title,
                subtitle: .subtitle,
                dismiss: dismiss
            )
            .safeAreaInset(edge: .bottom) {
               
                footer(state: state, event: event)
            }
            .opacity(state.isLoading ? 0.7 : 1)
            .disabled(state.isLoading)
            .loaderOverlay(isLoading: state.isLoading)
        }
    }
    
    @ViewBuilder
    private func confirmationView(
        _ confirmation: OpenSavingsAccountDomain.Confirmation,
        _ state: OpenSavingsAccountDomain.State,
        _ event: @escaping (OpenSavingsAccountDomain.Event) -> Void
    ) -> some View {
        
        makeOTPView(viewModel: confirmation.otp)
        makeConsent(state, event)
    }
    
    @ViewBuilder
    private func makeConsent(
        _ state: OpenSavingsAccountDomain.State,
        _ event: @escaping (OpenSavingsAccountDomain.Event) -> Void
    ) -> some View {
        
        if let form = state.loadableForm.state,
           let confirmation = form.confirmation.state {
            
            HStack {
                
                PaymentsCheckView.CheckBoxView(
                    isChecked: state.consent,
                    activeColor: .systemColorActive
                )
                .onTapGesture { event(.setConsent(!state.consent)) }
                
                Text(confirmation.consent.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
            }
            .animation(.easeInOut, value: state.consent)
        }
    }
    
    @ViewBuilder
    private func footer(
        state: OpenSavingsAccountDomain.State,
        event: @escaping (OpenSavingsAccountDomain.Event) -> Void
    ) -> some View {
        
        if let form = state.form,
           form.topUp.isOn,
           form.topUp.isShowFooter
        {
            AmountView(
                amount: form.amount,
                event: { event(.amount($0)) },
                currencySymbol: form.constants.currency.symbol,
                config: .iVortex,
                infoView: makeAmountInfoView
            )
        } else {
            // TODO: add amount
            StatefulButtonView(
                isActive: state.isValid,
                event: { event(.continue) },
                config: .iVortex(title: state.continueButtonTitle)
            )
            .padding(.horizontal)
        }
    }
}

// MARK: - Helpers

private extension OpenSavingsAccountDomain.State {
    
    var consent: Bool { loadableForm.state?.consent ?? false }
    
    var continueButtonTitle: String {
        
        hasConfirmation ? "Подтвердить и открыть" : "Открыть накопительный счет"
    }
    
    var isLoading: Bool {
        
        loadableForm.isLoading || isConfirmationLoading
    }
    
    var isConfirmationLoading: Bool {
        
        loadableForm.state?.confirmation.isLoading ?? false
    }
}

// MARK: - Adapters

extension OpenSavingsAccountDomain.LoadFailure: Identifiable {
    
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

private extension OpenSavingsAccountDomain.FlowDomain.State {
    
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

private extension String {
    
    static let title: Self = "Оформление"
    static let subtitle: Self = "накопительного счета"
}
