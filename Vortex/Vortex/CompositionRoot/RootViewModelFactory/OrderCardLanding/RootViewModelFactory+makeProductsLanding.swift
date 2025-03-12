//
//  RootViewModelFactory+makeProductsLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Foundation
import OrderCard
import OrderCardLandingBackend
import OrderCardLandingComponent
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeProductsLanding(
    ) -> ProductsLandingDomain.Binder {
    
        let content = makeProductsLandingContent()
        content.event(.load)
        
        return composeBinder(
            content: content,
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func makeProductsLandingContent(
    ) -> ProductsLandingDomain.Content {
        
        typealias Landing = ProductsLandingDomain.Content
        
        let reducer = ProductsLandingDomain.Reducer()
        let effectHandler = ProductsLandingDomain.EffectHandler(
            load: { [weak self] completion in
                
                self?.createProductLandingService { completion($0.loadResult) }
            }
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:event:),
            handleEffect: effectHandler.handleEffect(effect:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func getNavigation(
        select: ProductsLandingDomain.Select,
        notify: @escaping ProductsLandingDomain.Notify,
        completion: @escaping (ProductsLandingDomain.Navigation) -> Void
    ) {
        switch select {
        case .continue:
            break
            //TODO: add request and proccess
        }
    }

    @inlinable
    func createProductLandingService(
        completion: @escaping (Result<[OrderCardLandingComponent.Product], BackendFailure>) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createGetCardShowCaseRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetCardShowcaseResponse(_:_:),
            connectivityFailureMessage: .connectivity
        )
        
        service(()) {
            //TODO: extract helper
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                completion(
                    .success(response.products.map {
                        .init(
                            action: .init(
                                fallbackURL: $0.cardShowcaseAction.fallbackUrl,
                                target: $0.cardShowcaseAction.target,
                                type: $0.cardShowcaseAction.type
                            ),
                            imageURL: $0.image,
                            items: $0.features.list.map { .init(bullet: $0.bullet, title: $0.text)} ,
                            terms: $0.terms,
                            title: $0.name.first?.text ?? ""
                        )
                    })
                )
            }
        }
    }
}

private extension String {
    
    static let connectivity = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
}

// MARK: Adapters

private extension Result<[OrderCardLandingComponent.Product], BackendFailure> {
    
    var loadResult: Result<[OrderCardLandingComponent.Product], OrderCardLandingComponent.LoadFailure> {
        
        switch self {
        case let .success(landing):
            return .success(landing)
            
        case let .failure(error):
            return .failure(.init(
                message: error.message,
                type: .informer
            ))
        }
    }
}
