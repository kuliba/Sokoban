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

extension RootViewModelFactory {
    
    func makeCollateralLoanLandingShowcaseBinder() -> GetShowcaseDomain.Binder {
        
        composeBinder(
            content: makeContent(),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: witnesses()
        )
    }
        
    // MARK: - Content
    
    private func makeContent() -> GetShowcaseDomain.Content {
        
        let reducer = GetShowcaseDomain.Reducer()
        let effectHandler = GetShowcaseDomain.EffectHandler(load: loadCollateralLoanLanding)
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    private func loadCollateralLoanLanding(
        completion: @escaping(GetShowcaseDomain.Result) -> Void
    ) {
        // TODO: Fix error case
        //      return completion(.init(result: .failure(NSError(domain: "Showcase error", code: -1))))
        //      return completion(.init(result: .success(.init(serial: "", products: []))))
        
        let load = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetShowcaseRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateGetShowcaseResponse(_:_:)
        )
        
        load(nil) { [load] in
            
            completion(.init(result: $0))
            _ = load
        }
    }
    
    // MARK: - Flow
    
    private func delayProvider(
        navigation: GetShowcaseDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .landing:
            return .milliseconds(100)
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
        }
    }
    
    // Управление производится через Flow напрямую
    private func witnesses() -> ContentWitnesses<
        GetShowcaseDomain.Content,
        FlowEvent<GetShowcaseDomain.Select, Never>
    > {
        .init(
            emitting: { _ in Empty() },
            dismissing: { _ in {} }
        )
    }
}

private extension GetShowcaseDomain.Result {
    
    init(result: Result<RemoteServices.ResponseMapper.GetShowcaseData, Error>) {
        
        self = result.map { .init(products: $0.products.map(\.product)) }.mapError { _ in .init() }
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
