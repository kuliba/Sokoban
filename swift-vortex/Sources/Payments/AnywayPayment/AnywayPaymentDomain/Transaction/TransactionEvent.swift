//
//  TransactionEvent.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum TransactionEvent<TransactionReport, PaymentEvent, PaymentUpdate> {
    
    case completePayment(TransactionResult)
    case `continue`
    case dismissRecoverableError
    case fraud(FraudEvent)
    case initiatePayment
    case payment(PaymentEvent)
    case paymentRestartConfirmation(Bool)
    case updatePayment(UpdatePaymentResult)
    case verificationCode(VerificationCode)
}

public extension TransactionEvent {
    
    enum TransactionFailure: Equatable, Error {
        
        case otpFailure(String)
        case terminal(String)
    }
    
    typealias TransactionResult = Result<TransactionReport, TransactionFailure>
    
    typealias UpdatePaymentResult = Result<PaymentUpdate, ServiceFailure>
    
    enum VerificationCode: Equatable {
        
        case receive(GetVerificationCodeResult)
        case request
        
        public typealias ResendOTPCount = Int
        public typealias GetVerificationCodeResult = Result<ResendOTPCount, ServiceFailure>
    }
}

extension TransactionEvent: Equatable where TransactionReport: Equatable, PaymentEvent: Equatable, PaymentUpdate: Equatable {}
