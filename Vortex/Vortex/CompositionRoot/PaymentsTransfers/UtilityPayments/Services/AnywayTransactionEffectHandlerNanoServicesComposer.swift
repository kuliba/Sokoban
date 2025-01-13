//
//  AnywayTransactionEffectHandlerNanoServicesComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.05.2024.
//

import AnywayPaymentBackend
import AnywayPaymentDomain
import GenericRemoteService
import Foundation
import RemoteServices

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
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            getVerificationCode: getVerificationCode,
            initiatePayment: initiatePayment(),
            getDetails: getDetails(),
            makeTransfer: makeTransfer(),
            processPayment: processPayment()
        )
    }
    
    typealias NanoServices = AnywayTransactionEffectHandlerNanoServices
}

// MARK: - GetVerificationCode

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func getVerificationCode(
        _ completion: @escaping NanoServices.GetVerificationCodeCompletion
    ) {
        let createRequest = Vortex.RequestFactory.createGetVerificationCodeRequest
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapGetVerificationCodeResponse
        
        let service = LoggingRemoteServiceDecorator(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse,
            log: infoNetworkLog
        )
        
        service(()) {
            
            completion($0.map(\.resendOTPCount).mapError { .init($0) })
        }
    }
}

extension AnywayPaymentDomain.ServiceFailure {
    
    init(_ error: MappingError) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivity
            
        case let .mapResponse(error):
            switch error {
            case .invalid:
                self = .connectivity
                
            case let .server(_, errorMessage: errorMessage):
                self = .serverError(errorMessage)
            }
        }
    }
    
    static let connectivity: Self = .connectivityError("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже.")
    
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>
}

// MARK: - InitiatePayment

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func initiatePayment() -> InitiatePayment {
        
#warning("add logging")
        let process = Vortex.NanoServices.makeCreateAnywayTransferNewV2(httpClient, infoNetworkLog)
        
        return { digest, completion in
            
            process(.init(digest: digest)) {
                
                // dump($0, name: "makeCreateAnywayTransferNew result")
                completion($0.result)
                _ = process
            }
        }
    }
    
    typealias InitiatePayment = AnywayTransactionEffectHandlerNanoServices.InitiatePayment
}

// MARK: - GetDetails

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func getDetails() -> GetDetails {
        
        let createRequest = Vortex.RequestFactory.createGetOperationDetailByPaymentIDRequest
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        
        let service = LoggingRemoteServiceDecorator(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse,
            log: infoNetworkLog
        )
        
        return { payload, completion in
            
            return service(.init("\(payload)")) {
                
                completion(try? $0.get())
            }
        }
    }
    
    typealias GetDetails = AnywayTransactionEffectHandlerNanoServices.GetDetails
}

// MARK: - MakeTransfer

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func makeTransfer() -> MakeTransfer {
        
        let createRequest = Vortex.RequestFactory.createMakeTransferV2Request
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapMakeTransferResponse
        
        let service = LoggingRemoteServiceDecorator(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse,
            log: infoNetworkLog
        )
        
        return { payload, completion in
            
            return service(.init(payload.rawValue)) {
                
                completion($0.map(\.response).mapError { .init($0) })
            }
        }
    }
    
    typealias MakeTransfer = AnywayTransactionEffectHandlerNanoServices.MakeTransfer
}

// MARK: - ProcessPayment

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func processPayment() -> ProcessPayment {
        
        let process = Vortex.NanoServices.makeCreateAnywayTransferV2(httpClient, infoNetworkLog)
        
        return { digest, completion in
            
            process(.init(digest: digest)) { completion($0.result) }
        }
    }
    
    typealias ProcessPayment = AnywayTransactionEffectHandlerNanoServices.ProcessPayment
}

// MARK: - Log

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func networkLog(
        level: LoggerAgentLevel,
        message: @autoclosure () -> String,
        file: StaticString,
        line: UInt
    ) {
        log(level, .network, message(), file, line)
    }
    
    func infoNetworkLog(
        message: String,
        file: StaticString,
        line: UInt
    ) {
        log(.info, .network, message, file, line)
    }
}

// MARK: - Adapters

private extension AnywayTransactionEffectHandlerNanoServices.MakeTransferFailure {
    
    init(_ error: ServiceError) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .terminalFailure
            
        case let .mapResponse(mappingError):
            switch mappingError {
            case .invalid:
                self = .terminalFailure
                
            case let .server(statusCode, errorMessage):
                switch (statusCode, errorMessage) {
                case (102, "Введен некорректный код. Попробуйте еще раз."):
                    self = .otpFailure(errorMessage)
                    
                case let (102, errorMessage):
                    self = .terminal(errorMessage)
                    
                default:
                    self = .terminalFailure
                }
            }
        }
    }
    
    static let terminalFailure: Self = .terminal("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже.")
    
    typealias ServiceError = RemoteServiceError<any Error, any Error, RemoteServices.ResponseMapper.MappingError>
}

private extension NanoServices.CreateAnywayTransferResult {
    
    var result: Result<AnywayPaymentUpdate, AnywayPaymentDomain.ServiceFailure> {
        
        switch self {
        case let .failure(failure):
            return .failure(ServiceFailure(failure))
            
        case let .success(response):
            switch AnywayPaymentUpdate(response) {
            case .none:
                return .failure(.connectivity)
                
            case let .some(update):
                return .success(update)
            }
        }
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
            amount: digest.amount,
            check: true,
            comment: nil,
            currencyAmount: digest.core?.currency,
            mcc: nil,
            payer: digest.payer,
            puref: digest.puref
        )
    }
}

private extension AnywayPaymentDigest {
    
    var payer: NanoServices.CreateAnywayTransferPayload.Payer? {
        
        guard let core else { return nil }
        
        switch core.productType {
        case .account: return .init(accountID: core.productID)
        case .card:    return .init(cardID: core.productID)
        }
    }
}

private extension AnywayPaymentBackend.ResponseMapper.MakeTransferResponse {
    
    var response: AnywayTransactionEffectHandlerNanoServices.MakeTransferResponse {
        
        .init(status: self.status, detailID: operationDetailID, printForm: "")
    }
}

private extension AnywayPaymentBackend.ResponseMapper.MakeTransferResponse {
    
    var status: Vortex.DocumentStatus {
        
        switch documentStatus {
        case .complete:   return .completed
        case .inProgress: return .inflight
        case .rejected:   return .rejected
        }
    }
}

private extension AnywayPaymentDomain.ServiceFailure {
    
    init(_ error: AnywayPaymentBackend.ServiceFailure) {
        
        switch error {
        case .connectivityError:
            self = .connectivity
            
        case let .serverError(message):
            self = .serverError(message)
        }
    }
}
