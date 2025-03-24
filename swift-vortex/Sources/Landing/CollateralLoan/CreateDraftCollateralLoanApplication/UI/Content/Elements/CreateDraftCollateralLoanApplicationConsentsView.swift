//
//  CreateDraftCollateralLoanApplicationConsentsView.swift
//
//
//  Created by Valentin Ozerov on 31.01.2025.
//

import LinkableText
import OTPInputComponent
import SwiftUI

struct CreateDraftCollateralLoanApplicationConsentsView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel{
    
    let state: State
    let event: (Event) -> Void
    let externalEvent: (Domain.ExternalEvent) -> Void
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        VStack {
            
            ForEach(state.application.consents, id: (\.name), content: consent)
        }
        .padding(config.layouts.paddings.contentStack)
    }
    
    private func consent(_ consent: Consent) -> some View {

        HStack(spacing: 0) {
            
            Button(
                action: { event(.checkConsent(consent.name)) },
                label: {
                    state.checkedConsents.contains(consent.name)
                    ? config.elements.consent.images.checkOn.tint(config.elements.consent.imageColor)
                        : config.elements.consent.images.checkOff.tint(config.elements.consent.imageColor)
                })
            .frame(config.elements.consent.checkBoxSize)
            .padding(.trailing, config.elements.consent.horizontalSpacing)

            consent.name.text(withConfig: config.elements.consent.textConfig)
                .onTapGesture {
                    externalEvent(.showConsent(consent.link))
                }
            .frame(maxWidth: .infinity, alignment: .leading)
            .minimumScaleFactor(0.9)
        }
    }
}

extension CreateDraftCollateralLoanApplicationConsentsView {
    
    typealias Consent = CreateDraftCollateralLoanApplication.Consent
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Event = Domain.Event<Confirmation, InformerPayload>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationConsentsView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationConsentsView<Confirmation, InformerPayload>(
            state: .init(
                application: .preview,
                stage: .correctParameters,
                formatCurrency: { _ in "" }
            ),
            event: { print($0) },
            externalEvent: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Edit mode")
        
        CreateDraftCollateralLoanApplicationConsentsView<Confirmation, InformerPayload>(
            state: .init(
                application: .preview,
                stage: .confirm,
                formatCurrency: { _ in "" }
            ),
            event: { print($0) },
            externalEvent: { print($0) },
            config: .default,
            factory: .preview
        )
        .previewDisplayName("Read only mode")
    }
}

