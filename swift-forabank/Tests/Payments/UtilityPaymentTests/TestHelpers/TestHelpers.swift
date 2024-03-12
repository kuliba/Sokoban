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

// MARK: -

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

 func makeResponse(
    _ value: String = UUID().uuidString
) -> StartPaymentResponse {
    
    .init(value: value)
}

 func makeUtilityService(
    _ value: String = UUID().uuidString
) -> UtilityService {
    
    .init(value: value)
}

struct LastPayment: Equatable {
    
    var value: String
}

struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}

struct StartPaymentResponse: Equatable {
    
    var value: String
    
    var id: String { value }
}

struct UtilityService: Equatable {
    
    var value: String
    
    var id: String { value }
}

// MARK: -

func makeCreateAnywayTransferResponse(
) -> CreateAnywayTransferResponse {
    
    .init()
}

func makeFinalStepUtilityPayment(
    verificationCode: VerificationCode? = "654321"
) -> TestPayment {
    
    .init(
        isFinalStep: true,
        verificationCode: verificationCode
    )
}

func makeNonFinalStepUtilityPayment(
) -> TestPayment {
    
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
) -> TestPayment {
    
    .init(
        isFinalStep: isFinalStep,
        verificationCode: verificationCode,
        status: status
    )
}

struct CreateAnywayTransferResponse: Equatable {}

struct TestPayment: AnywayPayment {
    
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
