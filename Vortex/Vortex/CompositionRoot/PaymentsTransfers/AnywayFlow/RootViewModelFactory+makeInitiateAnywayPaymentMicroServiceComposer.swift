//
//  RootViewModelFactory+makeInitiateAnywayPaymentMicroServiceComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.11.2024.
//

import AnywayPaymentBackend
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeInitiateAnywayPaymentMicroServiceComposer(
    ) -> InitiateAnywayPaymentMicroServiceComposer {
        
        let initiatePayment = initiateAnywayPayment(puref:completion:)
        
        return .init(
            getOutlineProduct: { _ in self.model.outlineProduct() },
            processPayload: { payload, completion in
                
                initiatePayment(payload.outline.payload.puref) {
                    
                    switch $0 {
                    case let .failure(serviceFailure):
                        switch serviceFailure {
                        case .connectivityError:
                            completion(.failure(.connectivityError))
                            
                        case let .serverError(message):
                            completion(.failure(.serverError(message)))
                        }
                        
                    case let .success(response):
                        completion(.success(response))
                    }
                }
            }
        )
    }
    
    typealias CreateAnywayTransferResponse = RemoteServices.ResponseMapper.CreateAnywayTransferResponse
    typealias CreateAnywayTransferResult = Result<CreateAnywayTransferResponse, ServiceFailure>
    
    @inlinable
    func initiateAnywayPayment(
        puref: String,
        completion: @escaping (CreateAnywayTransferResult) -> Void
    ) {
        let createAnywayTransferNewV2 = nanoServiceComposer.compose(
            createRequest: RequestFactory.createCreateAnywayTransferNewV2Request,
            mapResponse: RemoteServices.ResponseMapper.mapCreateAnywayTransferResponse,
            mapError: ServiceFailure.init
        )
        
        createAnywayTransferNewV2(
            .init(additional: [], check: true, puref: puref)
        ) {
            completion($0)
            _ = createAnywayTransferNewV2
        }
    }
}
