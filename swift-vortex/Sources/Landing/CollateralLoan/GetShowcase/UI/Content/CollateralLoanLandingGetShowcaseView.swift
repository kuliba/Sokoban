//
//  CollateralLoanLandingGetShowcaseView.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetShowcaseView: View {
        
    private let data: Data
    private let event: (GetShowcaseViewEvent.External) -> Void
    private let config: Config
    private let theme: Theme
    
    public init(
        data: Data,
        event: @escaping (GetShowcaseViewEvent.External) -> Void,
        config: Config = .base,
        theme: Theme = .white
    ) {
        self.data = data
        self.event = event
        self.config = config
        self.theme = theme
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            ForEach(data.products, id: \.landingId) {
                
                CollateralLoanLandingGetShowcaseProductView(
                    product: $0,
                    event: event,
                    config: config
                )
            }
        }
    }
}

public enum GetShowcaseViewEvent: Equatable {
    
    case domainEvent(GetShowcaseDomain.Event)
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
}
