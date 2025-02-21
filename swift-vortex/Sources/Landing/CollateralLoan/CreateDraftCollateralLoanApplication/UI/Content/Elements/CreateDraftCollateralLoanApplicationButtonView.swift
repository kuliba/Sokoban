//
//  CreateDraftCollateralLoanApplicationButtonView.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

import SwiftUI
import OTPInputComponent

struct CreateDraftCollateralLoanApplicationButtonView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel{
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {
        
        Button(action: tapped) {
            
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: config.elements.button.layouts.height)
                .foregroundColor(config.elements.button.colors.foreground)
                .background(backgroundColor)
                .cornerRadius(config.elements.button.layouts.cornerRadius)
                .font(config.elements.button.font.font)
        }
        .disabled(!state.isButtonEnabled)
        .padding(config.elements.button.layouts.paddings)
    }
        
    private var title: String {
        
        state.stage == .correctParameters
            ? config.elements.button.continueTitle
            : config.elements.button.createTitle
    }
    
    private var backgroundColor: Color {
        
        state.isButtonEnabled
            ? config.elements.button.colors.background
            : config.elements.button.colors.disabled
    }
    
    private func tapped() {
        
        if state.stage == .correctParameters {
            
            event(.continue)
        } else {
            
            event(.submit)
        }
    }
}

extension CreateDraftCollateralLoanApplicationButtonView {
    
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias Event = Domain.Event<Confirmation, InformerPayload>
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationButtonView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel{
    
    static var previews: some View {
        
        VStack {
            
            CreateDraftCollateralLoanApplicationButtonView<Confirmation, InformerPayload>(
                state: .init(application: .preview),
                event: { print($0) },
                config: .default,
                factory: .preview
            )
        }
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
