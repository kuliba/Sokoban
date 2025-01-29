//
//  TransactionCompleteState.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.07.2024.
//

struct TransactionCompleteState {
    
    let details: TransactionDetailButton.Details?
    let operationDetail: OperationDetailData?
    let documentID: (DocumentID, String)?
    let status: Status
    
    enum Status {
        
        case completed, inflight, rejected, fraud
    }
}
