//
//  CollateralLoanLandingShowCaseView.swift
//
//
//  Created by Valentin Ozerov on 09.10.2024.
//

import SwiftUI

struct CollateralLoanLandingShowCaseView<SpinnerView, ContentView>: View
where SpinnerView: View,
      ContentView: View
{
    
    private var content: Content
    
    @State var isSpinnerShowing = true
    
    private let factory: Factory
    
    public init(
        content: Content,
        factory: Factory
    ) {
        
        self.content = content
        self.factory = factory
    }
    
    public var body: some View {
        
        switch content.viewState {
        case .content:
            ScrollView(showsIndicators: false) {
                ForEach(content.model.products, id: \.landingId) {
                    factory.makeView(with: $0)
                }
            }
        case .spinner:
            factory.makeSpinnerView()
        }
    }
}

extension CollateralLoanLandingShowCaseView {
    
    typealias Content = CollateralLoanLandingShowCaseContent
    typealias Factory = CollateralLoanLandingShowCaseViewFactory<SpinnerView, ContentView>
}
