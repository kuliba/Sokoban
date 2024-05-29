//
//  AnywayTransactionEffectHandlerMicroServices+stubbed.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import Foundation

extension AnywayTransactionEffectHandlerMicroServices {
    
    static func stubbed(
        with stub: Stub
    ) -> Self {
        
        return .init(
            initiatePayment: _initiatePayment(with: stub.initiatePayment),
            makePayment: _makePayment(with: stub.makePayment),
            paymentEffectHandle: { _,_ in }, // AnywayPaymentEffect is empty
            processPayment: _processPayment(with: stub.processPayment)
        )
    }
    
    struct Stub {
        
        let initiatePayment: ProcessResult
        let makePayment: Report?
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
        with stub: Report?
    ) -> MakePayment {
        
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
