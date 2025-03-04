//
//  CollateralLoanLandingGetShowcaseView.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetShowcaseView<InformerPayload>: View {
        
    private let data: Data
    private let event: (GetShowcaseViewEvent<InformerPayload>.External) -> Void
    private let config: Config
    private let theme: Theme
    private let factory: Factory
    
    public init(
        data: Data,
        event: @escaping (GetShowcaseViewEvent<InformerPayload>.External) -> Void,
        config: Config = .base,
        factory: Factory,
        theme: Theme = .white
    ) {
        self.data = data
        self.event = event
        self.config = config
        self.theme = theme
        self.factory = factory
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 0) {
                
                ForEach(data.products, id: \.landingId) {
                    
                    CollateralLoanLandingGetShowcaseProductView(
                        product: $0,
                        event: event,
                        config: config,
                        factory: factory
                    )
                }
            }
        }
    }
}

public enum GetShowcaseViewEvent<InformerPayload> {
    
    case domainEvent(GetShowcaseDomain.Event<InformerPayload>)
    case external(External)
    
    public enum External: Equatable {
        
        case showTerms(String)
        case showLanding(String)
    }
}

public extension CollateralLoanLandingGetShowcaseView {
    
    typealias Data = CollateralLoanLandingGetShowcaseData
    typealias Config = CollateralLoanLandingGetShowcaseViewConfig
    typealias Theme = CollateralLoanLandingGetShowcaseTheme
    typealias Event = GetShowcaseDomain.Event
    typealias Factory = CollateralLoanLandingFactory
}
