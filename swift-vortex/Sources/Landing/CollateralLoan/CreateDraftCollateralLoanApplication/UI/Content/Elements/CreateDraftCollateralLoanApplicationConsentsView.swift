//
//  CreateDraftCollateralLoanApplicationConsentsView.swift
//
//
//  Created by Valentin Ozerov on 31.01.2025.
//

import LinkableText
import SwiftUI

struct CreateDraftCollateralLoanApplicationConsentsView: View {
    
    let state: State
    let event: (Event) -> Void
    let externalEvent: (Domain.ExternalEvent) -> Void
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        VStack {
            
            ForEach(state.data.consents, id: (\.name), content: consent)
        }
        .padding(config.layouts.paddings.contentStack)
    }
    
    private func consent(_ consent: Consent) -> some View {

        HStack(spacing: 0) {
            
            Button(
                action: { event(.checkConsent(consent.name)) },
                label: {
                    state.checkedConditions.contains(consent.name)
                        ? config.elements.consent.images.checkOn
                        : config.elements.consent.images.checkOff
                })
            .frame(config.elements.consent.checkBoxSize)
            .padding(.trailing, config.elements.consent.horizontalSpacing)

            LinkableTextView(
                taggedText: "<u>" + consent.name + "</u>",
                urlString: consent.link,
                handleURL: { url in externalEvent(.showConsent(url)) }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .minimumScaleFactor(0.9)
        }
    }
}

extension CreateDraftCollateralLoanApplicationConsentsView {
    
    typealias Consent = CreateDraftCollateralLoanApplicationUIData.Consent
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias State = Domain.State
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationConsentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationConsentsView(
            state: .correntParametersPreview, 
            event: { print($0) },
            externalEvent: { print($0) },
            config: .default,
            factory: .preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
