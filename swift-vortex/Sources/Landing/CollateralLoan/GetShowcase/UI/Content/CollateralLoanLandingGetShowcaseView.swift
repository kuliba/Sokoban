//
//  CollateralLoanLandingGetShowcaseView.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetShowcaseView: View {
        
    private let data: Data
    private let event: (String) -> Void
    private let factory: Factory

    public init(
        data: Data,
        event: @escaping (String) -> Void,
        factory: Factory = Factory.init()
    ) {
        self.data = data
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            ForEach(data.products, id: \.landingId) {
                factory.makeView(with: $0, event: event)
            }
        }
    }
}

public extension CollateralLoanLandingGetShowcaseView {
    
    typealias Data = CollateralLoanLandingGetShowcaseData
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
}
