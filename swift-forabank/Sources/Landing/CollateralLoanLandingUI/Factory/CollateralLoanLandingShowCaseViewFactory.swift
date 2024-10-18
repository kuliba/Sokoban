//
//  CollateralLoanLandingShowCaseViewFactory.swift
//
//
//  Created by Valentin Ozerov on 10.10.2024.
//

import SwiftUI

public struct CollateralLoanLandingShowCaseViewFactory<ContentView, SpinnerView>
where ContentView: View,
      SpinnerView: View {
    
    public let makeContentView: MakeContentView
    public let makeSpinnerView: MakeSpinnerView

    let config: CollateralLoanLandingShowCaseViewConfig = .base

    public init(
        @ViewBuilder makeContentView: @escaping MakeContentView,
        @ViewBuilder makeSpinnerView: @escaping MakeSpinnerView
    ) {
        self.makeContentView = makeContentView
        self.makeSpinnerView = makeSpinnerView
    }
}

public extension CollateralLoanLandingShowCaseViewFactory {
    
    typealias MakeContentView = () -> ContentView
    typealias MakeSpinnerView = () -> SpinnerView
}
