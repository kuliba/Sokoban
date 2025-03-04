//
//  RootViewModelFactory+makeCollateralLoanLandingShowcaseBinder.swift
//  Vortex
//
//  Created by Valentin Ozerov on 23.12.2024.
//

import CollateralLoanLandingGetShowcaseBackend
import CollateralLoanLandingGetShowcaseUI
import RemoteServices
import RxViewModel
import Foundation
import Combine
import GenericRemoteService

extension RootViewModelFactory {
    
    func makeCollateralLoanLandingShowcaseBinder() -> GetShowcaseDomain.Binder {
        
        let content = makeContent()
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .init(
                emitting: { $0.$state
                        .compactMap { $0.result?.failure }
                        .map { .select(.failure($0.navigationFailure)) }
                        .eraseToAnyPublisher()
                },
                dismissing: { _ in { content.event(.dismissFailure) } }
            )
        )
    }
        
    // MARK: - Content
    
    private func makeContent() -> GetShowcaseDomain.Content {
        
        let reducer = GetShowcaseDomain.Reducer<InformerPayload>()
        let effectHandler = GetShowcaseDomain.EffectHandler<InformerPayload>(load: getShowcase)
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    private func getShowcase(
        completion: @escaping(GetShowcaseDomain.Result<InformerPayload>) -> Void
    ) {
        let load = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetShowcaseRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateGetShowcaseResponse(_:_:),
            mapError: GetShowcaseDomain.ContentError.init(error:)
        )
        
        load(nil) { [load] in
            
            completion($0.map { .init(products: $0.products.map(\.product)) })
            _ = load
        }
    }
    
    // MARK: - Flow
    
    private func delayProvider(
        navigation: GetShowcaseDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .landing: return .milliseconds(100)
        case .failure: return .milliseconds(100)
        }
    }
    
    private func getNavigation(
        select: GetShowcaseDomain.Select,
        notify: @escaping GetShowcaseDomain.Notify,
        completion: @escaping (GetShowcaseDomain.Navigation) -> Void
    ) {
        switch select {
        case let .landing(landingID):
            let collateralLoanLandingBinder = makeCollateralLoanLandingBinder(landingID: landingID)
            completion(.landing(landingID, collateralLoanLandingBinder))

        case let .failure(failure):
            switch failure {
            case let .informer(informerPayload):
                completion(.failure(.informer(informerPayload)))

            case let .alert(message):
                completion(.failure(.alert(message)))
            }
        }
    }
}

// MARK: Adapter

private extension RemoteServices.ResponseMapper.GetShowcaseData.Product {
    
    var product: CollateralLoanLandingGetShowcaseData.Product {
        
        .init(
            theme: theme.theme,
            name: name,
            terms: terms,
            landingId: landingId,
            image: image,
            keyMarketingParams: keyMarketingParams.keyMarketingParams,
            features: features.features
        )
    }
}

private extension RemoteServices.ResponseMapper.GetShowcaseData.Product.Theme {
    
    var theme: CollateralLoanLandingGetShowcaseData.Product.Theme {
        
        switch self {
        case .gray:
            return .gray
            
        case .white:
            return .white

        case .black:
            return .black
            
        case .unknown:
            return .unknown
        }
    }
}

private extension RemoteServices.ResponseMapper.GetShowcaseData.Product.KeyMarketingParams {
    
    var keyMarketingParams: CollateralLoanLandingGetShowcaseData.Product.KeyMarketingParams {
        
        .init(rate: rate, amount: amount, term: term)
    }
}

private extension RemoteServices.ResponseMapper.GetShowcaseData.Product.Features {
    
    var features: CollateralLoanLandingGetShowcaseData.Product.Features {
        
        .init(
            header: header,
            list: list.map(\.list)
        )
    }
}

private extension RemoteServices.ResponseMapper.GetShowcaseData.Product.Features.List {
    
    var list: CollateralLoanLandingGetShowcaseData.Product.Features.List {
        
        .init(bullet: bullet, text: text)
    }
}

extension GetShowcaseDomain.ContentError {
    
    typealias RemoteError = RemoteServiceError<Error, Error, RemoteServices.ResponseMapper.MappingError>
    
    init(
        error: RemoteError
    ) {
        switch error {
        case let .performRequest(error):
            if error.isNotConnectedToInternetOrTimeout() {
                self = .init(kind: .informer(.init(message: "Проверьте подключение к сети", icon: .wifiOff)))
            } else {
                self = .init(kind: .alert("Что-то пошло не так. Попробуйте позже."))
            }
            
        default:
            self = .init(kind: .alert(error.localizedDescription))
        }
    }
    
    var navigationFailure: GetShowcaseDomain.Failure {
        
        switch self.kind {
        case let .alert(message):
            return .alert(message)
            
        case let .informer(informerPayload):
            return .informer(informerPayload)
        }
    }
}
