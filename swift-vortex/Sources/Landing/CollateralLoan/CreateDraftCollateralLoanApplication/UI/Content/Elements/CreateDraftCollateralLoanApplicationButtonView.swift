//
//  CreateDraftCollateralLoanApplicationButtonView.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

import SwiftUI

struct CreateDraftCollateralLoanApplicationButtonView: View {
    
    @SwiftUI.State private var isDisabled = false
    
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
        .disabled(isDisabled)
        .padding(config.elements.button.layouts.paddings)
    }
        
    private var title: String {
        
        state.stage == .correctParameters
            ? config.elements.button.continueTitle
            : config.elements.button.createTitle
    }
    
    private var backgroundColor: Color {
        
        isDisabled
            ? config.elements.button.colors.disabled
            : config.elements.button.colors.background
    }
    
    private func tapped() {
        
        event(state.stage == .correctParameters ? .tappedContinue : .tappedSubmit)
    }
}

extension CreateDraftCollateralLoanApplicationButtonView {
    
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    typealias State = CreateDraftCollateralLoanApplicationDomain.State
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            CreateDraftCollateralLoanApplicationButtonView(
                state: .init(
                    data: .preview,
                    stage: .correctParameters
                ),
                event: { print($0) },
                config: .default,
                factory: .preview
            )
            .previewDisplayName("1st stage. Enabled button")
            
            CreateDraftCollateralLoanApplicationButtonView(
                state: .init(
                    data: .preview,
                    stage: .correctParameters
                ),
                event: { print($0) },
                config: .default,
                factory: .preview
            )
            .previewDisplayName("1st stage. Disabled button")

            CreateDraftCollateralLoanApplicationButtonView(
                state: .init(
                    data: .preview,
                    stage: .confirm
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
