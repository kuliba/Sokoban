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
    
    func makeOpenCardProductView(
        _ binder: OpenCardDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            makeOpenCardProductContentView(binder.content)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal)
                .alert(
                    item: state.failure,
                    content: { $0.alert(dismiss: dismiss) }
                )
        }
    }
    
    func makeOpenCardProductContentView(
        _ content: OpenCardDomain.Content
    ) -> some View {
        
        RxWrapperView(model: content) { state, event in
            
            switch state.result {
            case .none, .failure:
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.tertiary)
                    ._shimmering(isActive: state.result == nil)
                
            case let .success(form):
                switch form.confirmation {
                case .none:
                    Text("TBD: openCard Form without confirmation")
                    
                case .failure:
                    Text("TBD: openCard Form with confirmation failure")
                    
                case let .success(confirmation):
                    VStack {
                        
                        Text("TBD: openCard Form with confirmation")
                        
                        makeOTPView(viewModel: confirmation.otp)
                    }
                }
            }
        }
    }
    
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
    
    #warning("need to split alert and informer failure")
    var failure: OpenCardDomain.LoadFailure? {
        
        guard case let .failure(failure) = navigation
        else { return nil }
        
        return failure
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
