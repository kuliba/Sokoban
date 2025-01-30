//
//  CreateDraftCollateralLoanApplicationView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import RxViewModel
import SwiftUI
import InputComponent

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
            .alert(
                item: state.navigation?.alert,
                content: makeAlert
            )
            .fullScreenCover(cover: state.navigation?.cover, content: fullScreenCoverView)
        }
    }
    
    private func makeContentView(
        state: Domain.State,
        event: @escaping (Domain.Event) -> Void
    ) -> some View {
        
        CreateDraftCollateralLoanApplicationView(
            state: state,
            event: event,
            config: .default,
            factory: .init(
                makeImageViewByMD5hash: factory.makeImageViewByMD5hash,
                makeImageViewByURL: factory.makeImageViewByURL
            )
        )
    }

    private func makeAlert(
        alert: CreateDraftCollateralLoanApplicationDomain.Navigation.Alert
    ) -> SwiftUI.Alert {
        
        switch alert {
            
        case let .failure(failure):
            return .init(
                title: Text("Ошибка"),
                message: Text(failure),
                // TODO: + Action: возврат на гл. экран
                dismissButton: .default(Text("ОK")) { fatalError("Implement return to main view") }
            )
        }
    }
    
    @ViewBuilder
    private func fullScreenCoverView(
        cover: CreateDraftCollateralLoanApplicationDomain.Navigation.Cover
    ) -> some View {
        
        switch cover {
        case let .completed(completed):
            Text("completed")
        }
    }
}

extension CreateDraftCollateralLoanApplicationWrapperView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias MakeAnywayElementModelMapper = () -> AnywayElementModelMapper
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation {
    
    var alert: Alert? {
        
        switch self {
        case let .failure(failure):
            return .failure(failure)
            
        case .success:
            return nil
        }
    }

    enum Alert {
        
        case failure(String)
    }

    var cover: Cover? {
        
        switch self {
        case .failure:
            return nil
            
        case let .success(success):
            return .completed(success)
        }
    }
    
    enum Cover {
        // TODO: передавать данные для Cover
        case completed(String)
    }    
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Cover: Identifiable {
    
    var id: String {
        
        switch self {
        case let .completed(completed):
            return completed
        }
    }
}

extension CreateDraftCollateralLoanApplicationDomain.Navigation.Alert: Identifiable {
    
    var id: String {
        
        switch self {
        case let .failure(failure):
            return failure
        }
    }
}
