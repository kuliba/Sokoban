//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import UtilityPayment
import Foundation

func anyMessage() -> String {
    
    UUID().uuidString
}

// MARK: - factories

func makeLastPayment(
    _ value: String = UUID().uuidString
) -> LastPayment {
    
    .init(value: value)
}

func makeOperator(
    _ value: String = UUID().uuidString
) -> Operator {
    
    .init(value: value)
}

func makeOperatorOperators(
) -> (Operator, [Operator]) {
    
    let `operator` = makeOperator()
    let operators = [`operator`, makeOperator()]
    
    return (`operator`, operators)
}

func makePrepayment(
    _ lastPayments: [LastPayment] = [],
    _ operators: [Operator] = []
) -> Destination {
    
    .prepayment(.options(.init(
        lastPayments: lastPayments,
        operators: operators
    )))
}

func makeResponse(
    _ value: String = UUID().uuidString
) -> StartPaymentResponse {
    
    .init(value: value)
}

func makeService(
    _ value: String = UUID().uuidString
) -> Service {
    
    .init(value: value)
}

func makeServiceServices(
    _ value: String = UUID().uuidString
) -> (Service, [Service]) {
    
    let service = makeService()
    let services = [service, makeService()]
    
    return (service, services)
}

func makeServices() -> [Service] {
    
    [makeService(), makeService()]
}

func makeCreateAnywayTransferResponse(
    _ value: String = UUID().uuidString

) -> CreateAnywayTransferResponse {
    
    .init(value: value)
}

func makeFinalStepUtilityPayment(
    verificationCode: VerificationCode? = "654321"
) -> Payment {
    
    .init(
        isFinalStep: true,
        verificationCode: verificationCode
    )
}

func makeNonFinalStepUtilityPayment(
) -> Payment {
    
    .init(isFinalStep: false)
}

func makeVerificationCode(
    _ value: String = UUID().uuidString
) -> VerificationCode {
    
    .init(value)
}

func makeTransaction(
    _ detailID: Int = generateRandom11DigitNumber(),
    documentStatus: Transaction.DocumentStatus = .complete
) -> Transaction {
    
    .init(
        paymentOperationDetailID: .init(detailID),
        documentStatus: documentStatus
    )
}

func makeUtilityPayment(
    isFinalStep: Bool = false,
    verificationCode: VerificationCode? = nil,
    status: PaymentStatus? = nil
) -> Payment {
    
    .init(
        isFinalStep: isFinalStep,
        verificationCode: verificationCode,
        status: status
    )
}

// MARK: - Types

struct CreateAnywayTransferResponse: Equatable {
    
    var value: String
    
    var id: String { value }
}

struct LastPayment: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}

struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}

struct Payment: AnywayPayment {
    
#warning("TBD")
    // snapshots stack
    // fields
    
    var isFinalStep: Bool
    var verificationCode: VerificationCode?
    var status: PaymentStatus?
    
    init(
        isFinalStep: Bool = false,
        verificationCode: VerificationCode? = nil,
        status: PaymentStatus? = nil
    ) {
        self.isFinalStep = isFinalStep
        self.verificationCode = verificationCode
        self.status = status
    }
}

struct StartPaymentResponse: Equatable {
    
    var value: String
    
    var id: String { value }
}

struct Service: Equatable {
    
    var value: String
    
    var id: String { value }
}
