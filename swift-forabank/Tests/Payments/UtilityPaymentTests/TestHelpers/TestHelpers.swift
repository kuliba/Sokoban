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

struct TestPayment: Payment {
    
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
