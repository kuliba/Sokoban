//
//  RootViewModelFactory+makeInitiateAnywayPaymentMicroServiceComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.11.2024.
//

import AnywayPaymentBackend
import AnywayPaymentDomain
import GenericRemoteService
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeInitiateAnywayPaymentMicroServiceComposer(
    ) -> InitiateAnywayPaymentMicroServiceComposer {
        
        return .init(
            getOutlineProduct: getOutlineProduct(source:),
            processPayload: initiateAnywayPayment(output:completion:)
        )
    }
    
    @inlinable
    func getOutlineProduct(
        source: AnywayPaymentSourceParser.Source
    ) -> AnywayPaymentOutline.Product? {
        
        return model.outlineProduct()
    }
    
    typealias CreateAnywayTransferResponse = RemoteServices.ResponseMapper.CreateAnywayTransferResponse
    typealias CreateAnywayTransferResult = Result<CreateAnywayTransferResponse, ServiceFailureAlert.ServiceFailure>
    
    @inlinable
    func initiateAnywayPayment(
        output: AnywayPaymentSourceParser.Output,
        completion: @escaping (CreateAnywayTransferResult) -> Void
    ) {
        let createAnywayTransferNewV2 = nanoServiceComposer.compose(
            createRequest: RequestFactory.createCreateAnywayTransferNewV2Request,
            mapResponse: RemoteServices.ResponseMapper.mapCreateAnywayTransferResponse,
            mapError: ServiceFailureAlert.ServiceFailure.init
        )
        
        createAnywayTransferNewV2(.init(output: output)) {
            
            completion($0)
            _ = createAnywayTransferNewV2
        }
    }
}

// MARK: - Adapters

private extension RemoteServices.RequestFactory.CreateAnywayTransferPayload {
    
    init(output: AnywayPaymentSourceParser.Output) {
        
        self.init(additional: [], check: true, puref: output.outline.payload.puref)
    }
}

private extension ServiceFailureAlert.ServiceFailure {
    
    typealias RemoteError = RemoteServiceError<Error, Error, RemoteServices.ResponseMapper.MappingError>
    
    init(_ error: RemoteError) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivityError
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
            case .invalid:
                self = .connectivityError
                
            case let .server(_, message):
                self = .serverError(message)
            }
        }
    }
}
