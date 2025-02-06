//
//  RootViewModelFactory+openCardProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import Combine
// import OpenCardBackend
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func openCardProduct(
        notify: @escaping () -> Void
    ) -> OpenProduct.OpenCard {
        
        let content: OpenCardDomain.Content = makeContent()
        content.event(.load)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: witnesses()
        )
    }
    
    // MARK: - Content
    
    @inlinable
    func makeContent(
        initialState: OpenCardDomain.State = .init()
    ) -> OpenCardDomain.Content {
        
        let reducer = OpenCardDomain.Reducer()
        let effectHandler = OpenCardDomain.EffectHandler(
            load: load,
            loadConfirmation: loadConfirmation,
            orderCard: orderCard
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }
    
    // MARK: - Flow
    
    @inlinable
    func delayProvider(
        navigation: OpenCardDomain.Navigation
    ) -> Delay {
        
    }
    
    @inlinable
    func getNavigation(
        select: OpenCardDomain.Select,
        notify: @escaping OpenCardDomain.Notify,
        completion: @escaping (OpenCardDomain.Navigation) -> Void
    ) {
        
    }
    
    // MARK: - Bind
    
    @inlinable
    func witnesses() -> OpenCardDomain.Witnesses {
        
        return .init(
            emitting: {
                
                $0.$state.compactMap(\.failure)
                    .map { .select(.failure($0)) }
                    .eraseToAnyPublisher()
            },
            dismissing: { _ in {} } // TODO: add dismissing failure
        )
    }
    
    // MARK: - Services
    
    @inlinable
    func load(
        completion: @escaping (OpenCardDomain.LoadResult) -> Void
    ) {
//        let service = nanoServiceComposer.compose(
//            makeRequest: RequestFactory.createGetCardOrderFormRequest,
//            mapResponse: RemoteServices.ResponseMapper.mapGetCardOrderFormResponse
//        )
        let service: (@escaping (OpenCardDomain.LoadResult) -> Void) -> Void = { [weak self] completion in
            
            self?.schedulers.background.delay(for: .seconds(2)) {
             
                completion(.failure(.init(message: "Server failure", type: .alert)))
            }
        }
        
        schedulers.background.schedule {
            
            service { [service] in
                
                completion($0)
                _ = service
            }
        }
    }
    
    @inlinable
    func loadConfirmation(
        completion: @escaping (OpenCardDomain.LoadConfirmationResult) -> Void
    ) {
//        #warning("/verify/getVerificationCode")
//        let service = nanoServiceComposer.compose(
//            makeRequest: RequestFactory.createGetVerificationCodeVerifyRequest,
//            mapResponse: RemoteServices.ResponseMapper.mapGetVerificationCodeVerifyResponse
//        )
        
        let service: (@escaping (OpenCardDomain.LoadConfirmationResult) -> Void) -> Void = { [weak self] completion in
            
            self?.schedulers.background.delay(for: .seconds(2)) {
                
                completion(.failure(.init(message: "Server failure", type: .alert)))
            }
        }
        
        schedulers.background.schedule {
            
            service { [service] in
                
                completion($0)
                _ = service
            }
        }
    }
    
    @inlinable
    func orderCard(
        payload: OpenCardDomain.OrderCardPayload,
        completion: @escaping (OpenCardDomain.OrderCardResult) -> Void
    ) {
//        let service = nanoServiceComposer.compose(
//            makeRequest: RequestFactory.createOrderRequest,
//            mapResponse: RemoteServices.ResponseMapper.mapOrderCardResponse
//        )
        
        let service: (@escaping (OpenCardDomain.OrderCardResult) -> Void) -> Void = { [weak self] completion in
            
            self?.schedulers.background.delay(for: .seconds(2)) {
                
                completion(true)
            }
        }

        schedulers.background.schedule {
            
            service { [service] in
                
                completion($0)
                _ = service
            }
        }
    }
}
