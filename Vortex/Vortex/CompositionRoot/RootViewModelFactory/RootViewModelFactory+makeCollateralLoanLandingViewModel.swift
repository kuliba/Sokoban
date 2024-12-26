//
//  RootViewModelFactory+makeCollateralLoanLandingViewModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 23.12.2024.
//

import CollateralLoanLandingGetShowcaseBackend
import CollateralLoanLandingGetShowcaseUI
import RemoteServices
import RxViewModel
import Foundation

extension RootViewModelFactory {
    
    func makeCollateralLoanLandingViewModel(
        initialState: CollateralLoanLandingDomain.State = .init()
    ) -> CollateralLoanLandingDomain.ViewModel {
        
        let reducer = CollateralLoanLandingDomain.Reducer()
        let effectHandler = CollateralLoanLandingDomain.EffectHandler(load: loadCollateralLoanLanding)
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    private func loadCollateralLoanLanding(
        completion: @escaping(CollateralLoanLandingDomain.Result) -> Void
    ) {
        
        let load = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetShowcaseRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateGetShowcaseResponse(_:_:)
        )

        // TODO: Fix error case
//      return completion(.init(result: .failure(NSError(domain: "Showcase error", code: -1))))
//      return completion(.init(result: .success(.init(serial: "", products: []))))

        load(nil) { [load] in
            
            completion(.init(result: $0))
            _ = load
        }
    }
}

private extension CollateralLoanLandingDomain.Result {
    
    init(result: Result<RemoteServices.ResponseMapper.GetShowcaseData, Error>) {
        
        self = result.map { .init(products: $0.products.map(\.product)) }.mapError { _ in .init() }
    }
}

// MARK: Adapater
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
