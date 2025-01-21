//
//  CreateDraftCollateralLoanApplicationButtonView.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

import SwiftUI

struct CreateDraftCollateralLoanApplicationButtonView: View {
    
    let state: DomainState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {
        
        Button(action: tapped) {
            
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: config.button.layouts.height)
                .foregroundColor(config.button.colors.foreground)
                .background(backgroundColor)
                .cornerRadius(config.button.layouts.cornerRadius)
                .font(config.button.font.font)
        }
        .disabled(isDisabled)
        .padding(config.button.layouts.paddings)
    }
    
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    typealias State = CreateDraftCollateralLoanApplicationDomain.State
    
    private var isDisabled: Bool {
        
        state.stage == .correctParameters && !state.isValid
    }

    private var title: String {
        
        state.stage == .correctParameters ? config.button.continueTitle : config.button.createTitle
    }
    
    private var backgroundColor: Color {
        
        isDisabled
            ? config.button.colors.disabled
            : config.button.colors.background
    }
    
    private func tapped() {
        
        event(state.stage == .correctParameters ? .tappedContinue : .tappedSubmit)
    }
}

extension CreateDraftCollateralLoanApplicationButtonView {
    
    typealias DomainState = CreateDraftCollateralLoanApplicationDomain.State
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            CreateDraftCollateralLoanApplicationButtonView(
                state: .init(
                    data: .preview,
                    stage: .correctParameters,
                    isValid: true
                ),
                event: { print($0) },
                config: .default,
                factory: .preview
            )
            .previewDisplayName("1st stage. Enabled button")
            
            CreateDraftCollateralLoanApplicationButtonView(
                state: .init(
                    data: .preview,
                    stage: .correctParameters,
                    isValid: false
                ),
                event: { print($0) },
                config: .default,
                factory: .preview
            )
            .previewDisplayName("1st stage. Disabled button")

            CreateDraftCollateralLoanApplicationButtonView(
                state: .init(
                    data: .preview,
                    stage: .confirm,
                    isValid: false
                ),
                event: { print($0) },
                config: .default,
                factory: .preview
            )
            .previewDisplayName("2st stage")
        }
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}
