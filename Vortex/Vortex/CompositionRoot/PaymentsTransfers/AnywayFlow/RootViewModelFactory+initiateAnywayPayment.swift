//
//  RootViewModelFactory+initiateAnywayPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.12.2024.
//

import AnywayPaymentBackend
import AnywayPaymentCore
import AnywayPaymentDomain
import GenericRemoteService
import RemoteServices

extension RootViewModelFactory {
    
    typealias AnywayFlowModelCompletion = (Result<AnywayFlowModel, ServiceFailureAlert.ServiceFailure>) -> Void
    
    @inlinable
    func initiateAnywayPayment(
        payload: AnywayPaymentSourceParser.Source,
        completion: @escaping AnywayFlowModelCompletion
    ) {
        let anywayFlowComposer = makeAnywayFlowComposer()
        
        initiateAnywayPayment(payload) {

            completion($0.map(anywayFlowComposer.compose))
        }
    }
    
    typealias AnywayTransactionCompletion = (Result<AnywayTransactionState.Transaction, ServiceFailureAlert.ServiceFailure>) -> Void
    
    @inlinable
    func initiateAnywayPayment(
        _ payload: AnywayPaymentSourceParser.Source,
        completion: @escaping AnywayTransactionCompletion
    ) {
        let sourceParser = AnywayPaymentSourceParser(
            getOutlineProduct: getOutlineProduct
        )
        let validator = AnywayPaymentContextValidator()
        let transactionComposer = InitialAnywayTransactionComposer(
            isValid: { validator.validate($0) == nil }
        )
        
        let microService = InitiateAnywayPaymentMicroService(
            parseSource: sourceParser.parse,
            processPayload: initiateAnywayPayment(output:completion:),
            initiateTransaction: transactionComposer.compose
        )
        let initiatePayment = microService.initiatePayment
        
        initiatePayment(payload) {
            
            completion($0)
            _ = initiatePayment
        }
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

private extension AnywayPaymentSourceParser {
    
    func parse(_ source: Source) -> Output? {
        
        try? parse(source: source)
    }
}

private extension InitialAnywayTransactionComposer {
    
    func compose(
        _ output: AnywayPaymentSourceParser.Output,
        _ response: Response
    ) -> Transaction? {
        
        return compose(with: .init(output), and: response)
    }
}

private extension InitialAnywayTransactionComposer.Input {
    
    init(_ output: AnywayPaymentSourceParser.Output) {
        
        self.init(
            outline: output.outline,
            firstField: output.firstField
        )
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

private extension RemoteServices.RequestFactory.CreateAnywayTransferPayload {
    
    init(output: AnywayPaymentSourceParser.Output) {
        
        self.init(additional: [], check: true, puref: output.outline.payload.puref)
    }
}
