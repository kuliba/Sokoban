//
//  AnywayTransactionEffectHandlerNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.05.2024.
//

import AnywayPaymentBackend
import AnywayPaymentDomain
import GenericRemoteService
import Foundation

final class AnywayTransactionEffectHandlerNanoServicesComposer {
    
    private let httpClient: HTTPClient
    private let log: Log
    
    init(
        httpClient: HTTPClient,
        log: @escaping Log
    ) {
        self.httpClient = httpClient
        self.log = log
    }
}

extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            initiatePayment: initiatePayment,
            getDetails: getDetails,
            makeTransfer: makeTransfer,
            processPayment: processPayment
        )
    }
}

extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    typealias Log = (String, StaticString, UInt) -> Void
    
    typealias NanoServices = AnywayTransactionEffectHandlerNanoServices
}

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
#warning("add logging")
    private func initiatePayment(
        digest: AnywayPaymentDigest,
        completion: @escaping NanoServices.ProcessCompletion
    ) {
        let process = ForaBank.NanoServices.makeCreateAnywayTransferNew(httpClient, log)
        
        process(.init(digest: digest)) {
            
            dump($0, name: "makeCreateAnywayTransferNew result")
            completion($0.result) }
    }
    
#warning("add logging")
    private func getDetails(
        payload: OperationDetailID,
        completion: @escaping NanoServices.GetDetailsCompletion
    ) {
        let createRequest = ForaBank.RequestFactory.createGetOperationDetailByPaymentIDRequest
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        
        let service = RemoteService(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse
        )
        
        service(.init("\(payload)")) {
            
            completion(try? $0.map(\.response).get())
        }
    }
    
#warning("add logging")
    private func makeTransfer(
        payload: VerificationCode,
        completion: @escaping NanoServices.MakeTransferCompletion
    )  {
        let createRequest = ForaBank.RequestFactory.createMakeTransferRequest
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapMakeTransferResponse
        
        let service = RemoteService(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse
        )
        
        service(.init(payload.rawValue)) {
            
            completion(try? $0.map(\.response).get())
        }
    }
    
    private func processPayment(
        digest: AnywayPaymentDigest,
        completion: @escaping NanoServices.ProcessCompletion
    ) {
        let process = ForaBank.NanoServices.makeCreateAnywayTransfer(httpClient, log)
        process(.init(digest: digest)) { completion($0.result) }
    }
}

// MARK: - Adapters

private extension NanoServices.CreateAnywayTransferResult {
    
    var result: Result<AnywayPaymentUpdate, AnywayPaymentDomain.ServiceFailure> {
        dump(self, name: "NanoServices.CreateAnywayTransferResult")
        return self
            .map(AnywayPaymentUpdate.init)
            .mapError(ServiceFailure.init)
    }
}

private extension NanoServices.CreateAnywayTransferPayload {
    
    init(digest: AnywayPaymentDigest) {
        
#warning("FIXME")
#warning("add check to digest")
#warning("replace all hardcoded values")
        self.init(
            additional: digest.additional.map {
                
                .init(
                    fieldID: $0.fieldID,
                    fieldName: $0.fieldName,
                    fieldValue: $0.fieldValue
                )
            },
            amount: digest.core?.amount,
            check: true,
            comment: nil,
            currencyAmount: digest.core?.currency.rawValue,
            mcc: nil,
            payer: digest.payer,
            puref: digest.puref.rawValue
        )
    }
}

private extension AnywayPaymentDigest {
    
    var payer: NanoServices.CreateAnywayTransferPayload.Payer? {
        
        guard let core else { return nil }
        
        switch core.productID {
        case let .account(accountID):
            return .init(accountID: accountID.rawValue)
            
        case let .card(cardID):
            return .init(cardID: cardID.rawValue)
        }
    }
}

private extension AnywayPaymentBackend.ResponseMapper.MakeTransferResponse {
    
    var response: AnywayTransactionEffectHandlerNanoServices.MakeTransferResponse {
        
        .init(status: self.status, detailID: operationDetailID)
    }
}

private extension AnywayPaymentBackend.ResponseMapper.MakeTransferResponse {
    
    var status: ForaBank.DocumentStatus {
        
        switch documentStatus {
        case .complete:   return .completed
        case .inProgress: return .inflight
        case .rejected:   return .rejected
        }
    }
}

private extension AnywayPaymentBackend.ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
#warning("FIXME: replace with actual type (which is not String")
    var response: String {
        
        .init(describing: self)
    }
}

private extension AnywayPaymentDomain.ServiceFailure {
    
    init(_ error: AnywayPaymentBackend.ServiceFailure) {
        
        switch error {
        case .connectivityError:
            self = .connectivityError
            
        case let .serverError(message):
            self = .serverError(message)
        }
    }
}
