//
//  CollateralLoanLandingView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 25.12.2024.
//

import SwiftUI
import CollateralLoanLandingGetShowcaseUI
import RxViewModel

struct CollateralLoanLandingView: View {
    
    private let viewModel: GetShowcaseDomain.ViewModel
    private let factory: Factory
    
    init(
        viewModel: GetShowcaseDomain.ViewModel,
        factory: Factory
    ) {
        self.viewModel = viewModel
        self.factory = factory
    }
    
    var body: some View {
    
        RxWrapperView(model: viewModel, makeContentView: content(state:event:))
    }
    
    private func content(
        state: Domain.State,
        event: @escaping (Domain.Event) -> Void
    ) -> some View {
        
        Group {
            switch state.showcase {
            case .none:
                SpinnerView(viewModel: .init())
                
            case let .some(showcase):
                CollateralLoanLandingGetShowcaseView(data: showcase, factory: factory)
            }
        }
        .onFirstAppear { event(.load) }
    }
    
    typealias Domain = GetShowcaseDomain
    typealias Factory = CollateralLoanLandingGetShowcaseViewFactory
}
