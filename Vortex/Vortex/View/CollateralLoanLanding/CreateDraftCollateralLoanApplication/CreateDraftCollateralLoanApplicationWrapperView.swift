//
//  CreateDraftCollateralLoanApplicationView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import RxViewModel
import SwiftUI

struct CreateDraftCollateralLoanApplicationWrapperView: View {
    
    @Environment(\.openURL) var openURL
    
    let binder: Domain.Binder
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            RxWrapperView(
                model: binder.content,
                makeContentView: makeContentView(state:event:)
            )
        }
    }
    
    private func makeContentView(
        state: CreateDraftCollateralLoanApplicationDomain.State,
        event: @escaping (CreateDraftCollateralLoanApplicationDomain.Event) -> Void
    ) -> some View {
        
        CreateDraftCollateralLoanApplicationView(
            state: state,
            event: event,
            config: .default,
            factory: .init(
                makeImageViewWithMD5hash: factory.makeImageViewWithMD5hash,
                makeImageViewWithURL: factory.makeImageViewWithURL
            )
        )
    }
}
    
extension CreateDraftCollateralLoanApplicationWrapperView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
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
