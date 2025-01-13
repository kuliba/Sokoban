//
//  PaymentCompleteState.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.07.2024.
//

struct PaymentCompleteState {
    
    let formattedAmount: String
    let merchantIcon: String?
    let result: Result<Report, Fraud>
    
    struct Report {
        
        let detailID: Int
        let details: Details?
        let printFormType: String
        let status: DocumentStatus
        
        typealias Details = TransactionCompleteState.Details
    }
    
    struct Fraud: Equatable, Error {
        
        let hasExpired: Bool
    }
}
