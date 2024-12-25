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
    
    let viewModel: CollateralLoanLandingDomain.ViewModel
    
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
                CollateralLoanLandingGetShowcaseView(data: showcase)
            }
        }
        .onFirstAppear { event(.load) }
    }
    
    typealias Domain = CollateralLoanLandingDomain
}
