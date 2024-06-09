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
    
    func initiatePayment() -> InitiatePayment {
        
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
                
                // dump($0, name: "makeCreateAnywayTransferNew result")
                completion($0.result) }
        }
    }
    
    private func initiatePaymentStub(
        file: StaticString = #file,
        line: UInt = #line
    ) -> InitiatePayment {
        
        return { digest, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                let result = digest.initiatePaymentResultStub
                self.networkLog(level: .default, message: "Remote Service Initiate Payment Stub Result: \(result)", file: file, line: line)
                completion(result)
            }
        }
    }
    
    typealias InitiatePayment = AnywayTransactionEffectHandlerNanoServices.InitiatePayment
}

// MARK: - GetDetails

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func getDetails() -> GetDetails {
        
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
    
    private func getDetailsStub(
        file: StaticString = #file,
        line: UInt = #line
    ) -> GetDetails {
        
        return { payload, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                let result = payload.getDetailsResultStub
                self.networkLog(level: .default, message: "Remote Service Get Details Stub Result: \(String(describing: result))", file: file, line: line)
                completion(result)
            }
        }
    }
    
    typealias GetDetails = AnywayTransactionEffectHandlerNanoServices.GetDetails
}

// MARK: - MakeTransfer

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func makeTransfer() -> MakeTransfer {
        
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
    
    private func makeTransferStub(
        file: StaticString = #file,
        line: UInt = #line
    ) -> MakeTransfer {
        
        return { code, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                let result = code.makeTransferResultStub
                self.networkLog(level: .default, message: "Remote Service Make Transfer Stub Result: \(String(describing: result))", file: file, line: line)
                completion(result)
            }
        }
    }
    
    typealias MakeTransfer = AnywayTransactionEffectHandlerNanoServices.MakeTransfer
}

// MARK: - ProcessPayment

private extension AnywayTransactionEffectHandlerNanoServicesComposer {
    
    func processPayment() -> ProcessPayment {
        
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
    
    private func processPaymentStub(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProcessPayment {
        
        return { digest, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                let result = digest.processResultStub
                self.networkLog(level: .default, message: "Remote Service Process Payment Stub Result: \(result) for digest \(digest)", file: file, line: line)
                completion(result)
            }
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

private extension NanoServices.CreateAnywayTransferResult {
    
    var result: Result<AnywayPaymentUpdate, AnywayPaymentDomain.ServiceFailure> {
        // dump(self, name: "NanoServices.CreateAnywayTransferResult")
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
    
    var initiatePaymentResultStub: ProcessResult {
        
        .failure(.connectivityError)
    }
    
    var processResultStub: ProcessResult {
        
        if isStep4 { return .success(.init(.step4)) }
        if isStep4Fraud { return .success(.init(.step4Fraud)) }
        if isStep3Alert { return .failure(.connectivityError) }
        if isStep3 { return .success(.init(.step3)) }
        if isStep2Alert { return .failure(.serverError("Неверный лицевой счет.")) }
        if isStep2 { return .success(.init(.step2)) }
        
        return .failure(.connectivityError)
    }
    
    typealias ProcessResult = AnywayTransactionEffectHandlerNanoServices.ProcessResult
    
    private var isStep2Alert: Bool { containsAdditional(named: "1", withValue: "2222") }
    private var isStep2: Bool { containsAdditional(named: "1", withValue: "1111") }
    private var isStep3Alert: Bool { amount == 123 }
    private var isStep3: Bool { amount != nil }
    private var isStep4Fraud: Bool { containsAdditional(named: "SumSTrs", withValue: "22") }
    private var isStep4: Bool { containsAdditional(named: "SumSTrs", withValue: "11") }
    
    private func containsAdditional(
        named name: String,
        withValue value: String
    ) -> Bool {
        
        additional.contains {
            $0.fieldName == name
            && $0.fieldValue == value
        }
    }
}

private extension OperationDetailID {
    
    var getDetailsResultStub: GetDetailsResult {
        
        switch self {
        case 123: return ""
        default: return nil
        }
    }
    
    typealias GetDetailsResult = AnywayTransactionEffectHandlerNanoServices.GetDetailsResult
}

private extension VerificationCode {
    
    var makeTransferResultStub: MakeTransferResult {
        
        switch rawValue {
        case "111111": return .g1Completed
        case "222222": return .g1Inflight
        case "333333": return .g1Rejected
        default:       return .none
        }
    }
    
    typealias MakeTransferResult = AnywayTransactionEffectHandlerNanoServices.MakeTransferResult
}

private extension AnywayTransactionEffectHandlerNanoServices.MakeTransferResponse {
    
    static let g1Completed: Self = .init(status: .completed, detailID: 123)
    static let g1Inflight:  Self = .init(status: .inflight, detailID: 123)
    static let g1Rejected:  Self = .init(status: .rejected, detailID: 123)
}

private extension AnywayPaymentUpdate {
    
    static let preview: Self = .init(
        details: .preview,
        fields: [],
        parameters: []
    )
}

private extension AnywayPaymentUpdate.Details {
    
    static let preview: Self = .init(
        amounts: .preview,
        control: .preview,
        info: .preview
    )
}

private extension AnywayPaymentUpdate.Details.Amounts {
    
    static let preview: Self = .init(
        amount: nil,
        creditAmount: nil,
        currencyAmount: nil,
        currencyPayee: nil,
        currencyPayer: nil,
        currencyRate: nil,
        debitAmount: nil,
        fee: nil
    )
}

private extension AnywayPaymentUpdate.Details.Control {
    
    static let preview: Self = .init(
        isFinalStep: false,
        isFraudSuspected: false,
        isMultiSum: false,
        needMake: false,
        needOTP: false,
        needSum: false
    )
}

private extension AnywayPaymentUpdate.Details.Info {
    
    static let preview: Self = .init(
        documentStatus: nil,
        infoMessage: nil,
        payeeName: nil,
        paymentOperationDetailID: nil,
        printFormType: nil
    )
}
