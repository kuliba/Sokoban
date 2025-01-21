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
        
        CreateDraftCollateralLoanApplicationView(
            state: state,
            event: event,
            externalEvent: {
                switch $0 {
                case let .showSaveConsentsResult(saveConsentsResult):
                    print("######1: " + String(describing: saveConsentsResult))
                }
            },
            config: .default,
            factory: .init(
                makeImageViewWithMD5hash: factory.makeImageViewWithMD5hash,
                makeImageViewWithURL: factory.makeImageViewWithURL
            )
        )
    }
    
    @ViewBuilder
    private func destinationView(
        destination: CreateDraftCollateralLoanApplicationDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .showSaveConsentsResult(saveConsentsResult):
            Text("######2: " + String(describing: saveConsentsResult))
        }
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
        case let .showSaveConsentsResult(saveConsentsResult):
            return .showSaveConsentsResult(saveConsentsResult)
        }
    }

    enum Destination {
        
        case showSaveConsentsResult(CreateDraftCollateralLoanApplicationDomain.SaveConsentsResult)
    }

    enum Navigation {

        case showSaveConsentsResult(CreateDraftCollateralLoanApplicationDomain.SaveConsentsResult)
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation: Identifiable {
    
    var id: String {
        
        switch self {
        case .showSaveConsentsResult:
            return "showSaveConsentsResult"
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Destination: Identifiable {
    
    var id: String {
        
        switch self {
        case .showSaveConsentsResult:
            return "showSaveConsentsResult"
        }
    }
}
