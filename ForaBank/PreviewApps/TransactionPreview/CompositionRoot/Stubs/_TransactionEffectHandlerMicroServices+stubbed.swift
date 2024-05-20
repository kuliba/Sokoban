//
//  _TransactionEffectHandlerMicroServices+stubbed.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import Foundation

extension _TransactionEffectHandlerMicroServices {
    
    static func stubbed(
        with stub: Stub
    ) -> Self {
        
        return .init(
            initiatePayment: _initiatePayment(with: stub.initiatePayment),
            makePayment: _makePayment(with: stub.makePayment),
            paymentEffectHandle: _paymentEffectHandle(with: stub.paymentEffectHandle),
            processPayment: _processPayment(with: stub.processPayment)
        )
    }
    
    struct Stub {
        
        let initiatePayment: ProcessResult
        let makePayment: _TransactionReport?
        let paymentEffectHandle: PaymentEvent
        let processPayment: ProcessResult
    }
    
    private static func _initiatePayment(
        with stub: ProcessResult
    ) -> InitiatePayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    private static func _makePayment(
        with stub: _TransactionReport?
    ) -> MakePayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    private static func _paymentEffectHandle(
        with stub: PaymentEvent
    ) -> PaymentEffectHandle {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    private static func _processPayment(
        with stub: ProcessResult
    ) -> ProcessPayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
}
