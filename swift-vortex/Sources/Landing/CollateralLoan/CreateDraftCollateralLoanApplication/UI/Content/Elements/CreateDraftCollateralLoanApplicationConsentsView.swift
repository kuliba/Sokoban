//
//  CreateDraftCollateralLoanApplicationConsentsView.swift
//
//
//  Created by Valentin Ozerov on 31.01.2025.
//

import LinkableText
import SwiftUI

struct CreateDraftCollateralLoanApplicationConsentsView: View {
    
    let state: DomainState
    let externalEvents: (Domain.ExternalEvents) -> Void
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        VStack {
            
            ForEach(state.data.consents, id: (\.name), content: consent)
        }
    }
    
    private func consent(_ consent: Consent) -> some View {
        
        LinkableTextView(
            taggedText: "<u>" + consent.name + "</u>",
            urlString: consent.link,
            handleURL: { url in externalEvents(.showConsent(url)) }
        )
    }
}

extension CreateDraftCollateralLoanApplicationConsentsView {
    
    typealias Consent = CreateDraftCollateralLoanApplicationUIData.Consent
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias DomainState = Domain.State
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationConsentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationConsentsView(
            state: .correntParametersPreview,
            externalEvents: { print($0) },
            config: .default,
            factory: .preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
