//
//  CollateralLoanLandingShowCaseView.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseView {
    
    @ObservedObject private(set) var content: Content
    
    @State var isSpinnerShowing = true
    
    private let factory: Factory
    
    init(
        content: Content,
        factory: Factory
    ) {
        self.content = content
        self.factory = factory
    }
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            ForEach(content.data.products, id: \.landingId) {
                factory.makeView(with: $0)
            }
        }
    }
}

extension CollateralLoanLandingShowCaseView {
    
    typealias Content = CollateralLoanLandingShowCaseContent
    typealias Factory = CollateralLoanLandingShowCaseViewFactory
}
