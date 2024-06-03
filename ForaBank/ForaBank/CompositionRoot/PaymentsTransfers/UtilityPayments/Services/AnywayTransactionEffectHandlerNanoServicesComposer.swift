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
    
    private let flag: Flag
    private let httpClient: HTTPClient
    private let log: Log
    
    init(
        flag: Flag,
        httpClient: HTTPClient,
        log: @escaping Log
    ) {
        self.flag = flag
        self.httpClient = httpClient
        self.log = log
    }
    
    typealias Flag = StubbedFeatureFlag.Option
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            initiatePayment: initiatePayment(),
            getDetails: getDetails(),
            makeTransfer: makeTransfer(),
            processPayment: processPayment()
        )
    }
    
    typealias NanoServices = AnywayTransactionEffectHandlerNanoServices
}

// MARK: - InitiatePayment

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    private func initiatePayment() -> InitiatePayment {
        
        switch flag {
        case .live: return initiatePaymentLive()
        case .stub: return initiatePaymentStub()
        }
    }
    
#warning("add logging")
    private func initiatePaymentLive() -> InitiatePayment {
        
        let process = ForaBank.NanoServices.makeCreateAnywayTransferNewV2(httpClient, infoNetworkLog)
        
        return { digest, completion in
            
            process(.init(digest: digest)) {
                
                dump($0, name: "makeCreateAnywayTransferNew result")
                completion($0.result) }
        }
    }
    
    private func initiatePaymentStub() -> InitiatePayment {
        
        return { digest, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
     
                let result = digest.matchingInitiatePaymentResultStub
                self.networkLog(level: .default, message: "Remote Service Initiate Payment Stub Result: \(result)", file: #file, line: #line)
                completion(result)
            }
        }
    }
    
    typealias InitiatePayment = AnywayTransactionEffectHandlerNanoServices.InitiatePayment
}

// MARK: - GetDetails

private extension AnywayTransactionEffectHandlerNanoServicesComposer {

    private func getDetails() -> GetDetails {
        
        switch flag {
        case .live: return getDetailsLive()
        case .stub: return getDetailsStub()
        }
    }
    
    private func getDetailsLive() -> GetDetails {
        
        let createRequest = ForaBank.RequestFactory.createGetOperationDetailByPaymentIDRequest
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        
        let service = LoggingRemoteServiceDecorator(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse,
            log: infoNetworkLog
        )
        
        return { payload, completion in
            
            return service(.init("\(payload)")) {
                
                completion(try? $0.map(\.response).get())
            }
        }
    }
    
    private func getDetailsStub() -> GetDetails {
        
        return { payload, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                let result = payload.matchingGetDetailsResultStub
                self.networkLog(level: .default, message: "Remote Service Get Details Stub Result: \(String(describing: result))", file: #file, line: #line)
                completion(result)
            }
        }
    }
    
    typealias GetDetails = AnywayTransactionEffectHandlerNanoServices.GetDetails
}

// MARK: - MakeTransfer

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    private func makeTransfer() -> MakeTransfer {
        
        switch flag {
        case .live: return makeTransferLive()
        case .stub: return makeTransferStub()
        }
    }
    
    private func makeTransferLive() -> MakeTransfer {
        
        let createRequest = ForaBank.RequestFactory.createMakeTransferRequest
        let mapResponse = AnywayPaymentBackend.ResponseMapper.mapMakeTransferResponse
        
        let service = LoggingRemoteServiceDecorator(
            createRequest: createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: mapResponse,
            log: infoNetworkLog
        )
        
        return { payload, completion in
            
            return service(.init(payload.rawValue)) {
                
                completion(try? $0.map(\.response).get())
            }
        }
    }
    
    private func makeTransferStub() -> MakeTransfer {
        
        return { code, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
     
                let result = code.matchingMakeTransferStub
                self.networkLog(level: .default, message: "Remote Service Make Transfer Stub Result: \(String(describing: result))", file: #file, line: #line)
                completion(result)
            }
        }
    }
    
    typealias MakeTransfer = AnywayTransactionEffectHandlerNanoServices.MakeTransfer
}

// MARK: - ProcessPayment

private extension AnywayTransactionEffectHandlerNanoServicesComposer {

    private func processPayment() -> ProcessPayment {
        
        switch flag {
        case .live: return processPaymentLive()
        case .stub: return processPaymentStub()
        }
    }
    
    private func processPaymentLive() -> ProcessPayment {
        
        let process = ForaBank.NanoServices.makeCreateAnywayTransferV2(httpClient, infoNetworkLog)
        
        return { digest, completion in
            
            process(.init(digest: digest)) { completion($0.result) }
        }
    }
    
    private func processPaymentStub() -> ProcessPayment {
        
        return { digest, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
     
                let result = digest.matchingProcessResultStub
                self.networkLog(level: .default, message: "Remote Service Process Payment Stub Result: \(result)", file: #file, line: #line)
                completion(result)
            }
        }
    }
    
    typealias ProcessPayment = AnywayTransactionEffectHandlerNanoServices.ProcessPayment
}

// MARK: - Log

private extension AnywayTransactionEffectHandlerNanoServicesComposer {

    private func networkLog(
        level: LoggerAgentLevel,
        message: @autoclosure () -> String,
        file: StaticString,
        line: UInt
    ) {
        log(level, .network, message(), file, line)
    }
    
    private func infoNetworkLog(
        message: String,
        file: StaticString,
        line: UInt
    ) {
        log(.info, .network, message, file, line)
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

// MARK: - Stubs

private extension AnywayPaymentDigest {
    
    var matchingInitiatePaymentResultStub: ProcessResult {
        
        .failure(.connectivityError)
    }
        
    var matchingProcessResultStub: ProcessResult {
        
        .failure(.connectivityError)
    }
    
    typealias ProcessResult = AnywayTransactionEffectHandlerNanoServices.ProcessResult
}

private extension OperationDetailID {
    
    var matchingGetDetailsResultStub: GetDetailsResult {
        
        nil
    }
    
    typealias GetDetailsResult = AnywayTransactionEffectHandlerNanoServices.GetDetailsResult
}

private extension VerificationCode {
    
    var matchingMakeTransferStub: MakeTransferResult {
        
        nil
    }
    
    typealias MakeTransferResult = AnywayTransactionEffectHandlerNanoServices.MakeTransferResult
}
