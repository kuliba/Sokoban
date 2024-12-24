//
//  RootViewModelFactory+makeCollateralLoanLandingViewModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 23.12.2024.
//

import CollateralLoanLandingGetShowcaseBackend
import RemoteServices
import RxViewModel

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
        
        load(nil) { [load] in
            
            completion(.init(result: $0))
            _ = load
        }
        
//        let load = loggingSerialLoaderComposer.compose(
//            createRequest: RequestFactory.createGetShowcaseRequest,
//            mapResponse: RemoteServices.ResponseMapper.mapCreateGetShowcaseResponse(_:_:),
//            fromModel: <#T##(Model) -> T#>,
//            toModel: <#T##(T) -> Model#>
//        )
    }
}

private extension CollateralLoanLandingDomain.Result {
    
    init(result: Result<RemoteServices.ResponseMapper.GetShowcaseData, Error>) {
        
        self = result.map { _ in fatalError() }.mapError { _ in .init() }
    }
}

// TODO: Add adapater
