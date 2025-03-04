//
//  RootViewModelFactory+makeOrderCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 25.02.2025.
//

import Foundation
import HeaderLandingComponent
import ListLandingComponent
import OrderCardLandingBackend
import RemoteServices
import DropDownTextListComponent

extension RootViewModelFactory {
    
    @inlinable
    func makeOrderCardLanding(
    ) -> OrderCardLandingDomain.Binder {
        
        composeBinder(
            content: makeOrderCardLandinContent(),
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func makeOrderCardLandinContent(
    ) -> OrderCardLandingDomain.Content {
        
        typealias Landing = OrderCardLanding
        
        let reducer = LandingReducer<Landing>()
        let effectHandler = LandingEffectHandler<Landing>(
            load: { completion in
                
                self.createOrderCardLanding { result in
                    
                    switch result {
                    case let .success(landing):
                        completion(.success(landing))
                    case let .failure(error):
                        completion(
                            .failure(
                                .init(
                                    message: error.message,
                                    type: .informer
                                )
                            )
                        )
                    }
                }
            }
        )
        
        return .init(
            initialState: .init(isLoading: true, status: .none),
            reduce: reducer.reduce(_:event:),
            handleEffect: effectHandler.handleEffect(effect:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func getNavigation(
        select: OrderCardLandingDomain.Select,
        notify: @escaping OrderCardLandingDomain.Notify,
        completion: @escaping (OrderCardLandingDomain.Navigation) -> Void
    ) {
        switch select {
        case .continue:
            break
            //TODO: add request and proccess
        }
    }
    
    @inlinable
    func createOrderCardLanding(
        completion: @escaping (ModelOrderPayloadResult) -> Void
    ) {

        createOrderCardLandingService() { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(payload):
                completion(.success(payload))
            }
        }
    }
    
    typealias ModelOrderPayloadResult = Result<OrderCardLanding, BackendFailure>

    @inlinable
    func createOrderCardLandingService(
        completion: @escaping (ModelOrderPayloadResult) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createGetDigitalCardLandingRequest,
            mapResponse: RemoteServices.ResponseMapper.mapOrderCardLandingResponse,
            connectivityFailureMessage: .connectivity
        )
        
        service(()) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                completion(.success(.init(response)))
            }
        }
    }
}

private extension OrderCardLanding {

    init(_ response: OrderCardLandingResponse) {
        self.init(
            header: .init(product: response.product),
            conditions: .init(conditions: response.conditions),
            security: .init(security: response.security),
            dropDownList: .init(questions: response.frequentlyAskedQuestions)
        )
    }
}

private extension DropDownTextList {

    init(questions: OrderCardLandingResponse.Question) {
        self.init(
            title: questions.title,
            items: questions.list.compactMap({
                .init(
                    title: $0.title,
                    subTitle: $0.subtitle ?? ""
                )
            })
        )
    }
}

private extension ListLandingComponent.Items {
    
    init(security: OrderCardLandingResponse.Security) {
        self.init(
            title: security.title,
            list: security.list.compactMap({
                .init(
                    md5hash: $0.md5hash,
                    title: $0.title,
                    subtitle: $0.subtitle
                )
            })
        )
    }
}

private extension ListLandingComponent.Items {

    init(conditions: OrderCardLandingResponse.Condition) {
        self.init(
            title: conditions.title,
            list: conditions.list.compactMap({
                .init(
                    md5hash: $0.md5hash,
                    title: $0.title,
                    subtitle: $0.subtitle
                )
            })
        )
    }
}

private extension Header {

    init(product: OrderCardLandingResponse.Product) {
        
        self.init(
            title: product.title, 
            navTitle: product.navTitle,
            navSubtitle: product.navSubtitle,
            options: product.features,
            imageUrl: product.image
        )
    }
}

private extension String {
    
    static let connectivity = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
}
