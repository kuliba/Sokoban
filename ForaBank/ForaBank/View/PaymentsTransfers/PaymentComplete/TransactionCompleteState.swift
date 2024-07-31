//
//  TransactionCompleteState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

struct TransactionCompleteState {
    
    let details: Details?
    let documentID: DocumentID?
    let status: Status
    
    typealias Details = TransactionDetailButton.Details
    
    enum Status {
        
        case completed, inflight, rejected, fraud
    }
}
