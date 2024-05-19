//
//  TransactionEffectHandlerNanoServices+stubbed.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import Foundation

extension TransactionEffectHandlerNanoServices {
    
    static func stubbed(
        with stub: Stub
    ) -> Self {
        
        return .init(
            getDetails: _getDetails(stub: stub.getDetailsResult),
            makeTransfer: _makeTransfer(stub: stub.makeTransferResult)
        )
    }
    
    struct Stub {
        
        let getDetailsResult: GetDetailsResult
        let makeTransferResult: MakeTransferResult
    }
    
    private static func _getDetails(
        stub: GetDetailsResult
    ) -> GetDetails {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
    
    private static func _makeTransfer(
        stub: MakeTransferResult
    ) -> MakeTransfer {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) {
                
                completion(stub)
            }
        }
    }
}
