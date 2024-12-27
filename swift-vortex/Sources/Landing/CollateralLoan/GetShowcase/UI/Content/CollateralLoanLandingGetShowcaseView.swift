//
//  CollateralLoanLandingGetShowcaseView.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetShowcaseView: View {
    
    private let data: CollateralLoanLandingGetShowcaseData
    private let factory: Factory

    public init(data: Data, factory: Factory) {
        self.data = data
        self.factory = factory
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            ForEach(data.products, id: \.landingId) {
                factory.makeView(with: $0)
            }
        }
    }
}

extension CollateralLoanLandingGetShowcaseView {
    
    public typealias Data = CollateralLoanLandingGetShowcaseData
    public typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
}
