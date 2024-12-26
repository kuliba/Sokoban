//
//  CollateralLoanLandingGetShowcaseView.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingGetShowcaseView: View {
    
    public let data: CollateralLoanLandingGetShowcaseData
    
    private let factory = Factory()
    
    public init(data: CollateralLoanLandingGetShowcaseData) {
        self.data = data
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
    
    typealias Data = CollateralLoanLandingGetShowcaseData
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
}
