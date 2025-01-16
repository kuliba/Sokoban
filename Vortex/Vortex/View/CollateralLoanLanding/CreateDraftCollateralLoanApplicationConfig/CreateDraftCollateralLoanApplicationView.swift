//
//  CreateDraftCollateralLoanApplicationView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import RxViewModel
import SwiftUI

struct CreateDraftCollateralLoanApplicationView: View {
    
    @Environment(\.openURL) var openURL
    
    let binder: CreateDraftCollateralLoanApplicationDomain.Binder
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            RxWrapperView(
                model: binder.content,
                makeContentView: makeContentView(state:event:)
            )
            .navigationDestination(
                destination: state.navigation?.destination,
                content: destinationView
            )
        }
    }
    
    private func makeContentView(
        state: CreateDraftCollateralLoanApplicationDomain.State,
        event: @escaping (CreateDraftCollateralLoanApplicationDomain.Event) -> Void
    ) -> some View {
        
        Text("CreateDraftCollateralLoanApplicationView")
    }
    
    @ViewBuilder
    private func destinationView(
        destination: CreateDraftCollateralLoanApplicationDomain.Navigation.Destination
    ) -> some View {
        
        Text("destinationView")
    }
}

extension CreateDraftCollateralLoanApplicationView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation {

    var destination: Destination? {
        
        switch self {
        case let .submitAnApplication(payload):
            return .submitAnApplication(payload)
        }
    }

    enum Destination {
        
        case submitAnApplication(String)
    }

    enum Navigation {

        case submitAnApplication(String)
        
        enum Destination {}
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation: Identifiable {
    
    var id: String {
        
        switch self {
        case let .submitAnApplication(payload):
                return payload
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Destination: Identifiable {
    
    var id: String {
        
        switch self {
        case let .submitAnApplication(payload): return payload
        }
    }
}
